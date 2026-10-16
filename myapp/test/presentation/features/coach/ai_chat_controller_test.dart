// Covers: the AI coach chat — consent, sending, photos, failures with retry,
// and reporting a reply (store-compliance §5)
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/presentation/providers/ai_chat_controller.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

class _Service implements AiCoachService {
  final List<Result<String>> answers = [];
  final List<({List<AiMessage> history, String question, int photos})> asked =
      [];
  final List<({String id, String reason})> reports = [];
  Result<void> reportResult = const Ok(null);

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async {
    asked.add((history: history, question: question, photos: photos.length));
    return answers.isEmpty
        ? const Ok('A helpful answer.')
        : answers.removeAt(0);
  }

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async {
    reports.add((id: reply.id, reason: reason));
    return reportResult;
  }
}

class _Picker implements AiPhotoPicker {
  Result<Uint8List?> next = Ok(Uint8List.fromList([1, 2, 3]));
  final List<AiPhotoSource> asked = [];

  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async {
    asked.add(source);
    return next;
  }
}

void main() {
  late _Service service;
  late _Picker picker;
  late ProviderContainer c;

  setUp(() async {
    service = _Service();
    picker = _Picker();
    c = ProviderContainer(
      overrides: [
        aiCoachServiceProvider.overrideWithValue(service),
        aiPhotoPickerProvider.overrideWithValue(picker),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(c.dispose);
    c.listen(aiChatControllerProvider, (_, _) {});
    c.listen(aiConsentStateProvider, (_, _) {});
    // The user has agreed.
    await c.read(aiConsentStateProvider.notifier).give();
  });

  AiChatState state() => c.read(aiChatControllerProvider);
  AiChatController chat() => c.read(aiChatControllerProvider.notifier);

  group('consent', () {
    test('starts as not given, once the phone has been asked', () async {
      final fresh = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(service),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
      );
      addTearDown(fresh.dispose);
      fresh.listen(aiConsentStateProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fresh.read(aiConsentStateProvider), isFalse);
    });

    test('giving and withdrawing it', () async {
      expect(c.read(aiConsentStateProvider), isTrue);
      await c.read(aiConsentStateProvider.notifier).withdraw();
      expect(c.read(aiConsentStateProvider), isFalse);
      await c.read(aiConsentStateProvider.notifier).give();
      expect(c.read(aiConsentStateProvider), isTrue);
    });

    test('withdrawing also wipes the chat', () async {
      await chat().send('Hello', languageCode: 'en');
      expect(state().messages, isNotEmpty);
      await c.read(aiConsentStateProvider.notifier).withdraw();
      expect(state().messages, isEmpty);
    });
  });

  group('sending', () {
    test('the question and the answer both appear', () async {
      await chat().send('Is my routine ok?', languageCode: 'en');
      expect(state().messages.map((m) => (m.role, m.text)), [
        (AiRole.user, 'Is my routine ok?'),
        (AiRole.assistant, 'A helpful answer.'),
      ]);
      expect(state().sending, isFalse);
      expect(state().failure, isNull);
    });

    test('the chat so far goes along with the next question', () async {
      await chat().send('First', languageCode: 'en');
      await chat().send('Second', languageCode: 'en');
      expect(service.asked.last.question, 'Second');
      expect(service.asked.last.history.map((m) => m.text), [
        'First',
        'A helpful answer.',
      ]);
    });

    test('it says it is sending while it waits', () async {
      final future = chat().send('Hi', languageCode: 'en');
      expect(state().sending, isTrue);
      await future;
      expect(state().sending, isFalse);
    });

    test('an empty message with no photo is ignored', () async {
      await chat().send('   ', languageCode: 'en');
      expect(state().messages, isEmpty);
      expect(service.asked, isEmpty);
    });

    test('a second message is ignored while one is on its way', () async {
      final first = chat().send('One', languageCode: 'en');
      final second = chat().send('Two', languageCode: 'en');
      await Future.wait([first, second]);
      expect(service.asked, hasLength(1));
    });
  });

  group('photos', () {
    test(
      'attaching adds a photo and asks the picker for that source',
      () async {
        await chat().attach(AiPhotoSource.camera);
        expect(state().pendingPhotos, hasLength(1));
        expect(picker.asked, [AiPhotoSource.camera]);
      },
    );

    test('a cancelled picker adds nothing', () async {
      picker.next = const Ok<Uint8List?>(null);
      await chat().attach(AiPhotoSource.gallery);
      expect(state().pendingPhotos, isEmpty);
      expect(state().photoFailed, isFalse);
    });

    test('a failed picker says so', () async {
      picker.next = const Err(UnknownFailure('pick'));
      await chat().attach(AiPhotoSource.gallery);
      expect(state().photoFailed, isTrue);
    });

    test('no more than three', () async {
      for (var i = 0; i < 5; i++) {
        await chat().attach(AiPhotoSource.gallery);
      }
      expect(state().pendingPhotos, hasLength(3));
    });

    test('a photo can be removed', () async {
      await chat().attach(AiPhotoSource.gallery);
      chat().removePhoto(0);
      expect(state().pendingPhotos, isEmpty);
    });

    test('they are sent with the message and then cleared', () async {
      await chat().attach(AiPhotoSource.gallery);
      await chat().attach(AiPhotoSource.camera);
      await chat().send('What do you see?', languageCode: 'en');
      expect(service.asked.single.photos, 2);
      expect(state().messages.first.photoCount, 2);
      expect(state().pendingPhotos, isEmpty);
    });

    test('a photo alone is a question', () async {
      await chat().attach(AiPhotoSource.gallery);
      await chat().send('', languageCode: 'en');
      expect(service.asked.single.photos, 1);
      expect(state().messages, hasLength(2));
    });
  });

  group('when it goes wrong', () {
    test('the question stays and the failure is shown', () async {
      service.answers.add(const Err(NetworkFailure()));
      await chat().send('Hello', languageCode: 'en');
      expect(state().messages.map((m) => m.text), ['Hello']);
      expect(state().failure, const NetworkFailure());
      expect(state().sending, isFalse);
    });

    test('Try again sends the same question and clears the failure', () async {
      service.answers.add(const Err(NetworkFailure()));
      await chat().send('Hello', languageCode: 'en');
      await chat().retry(languageCode: 'en');
      expect(state().failure, isNull);
      expect(state().messages.map((m) => m.text), [
        'Hello',
        'A helpful answer.',
      ]);
      // The user's question is not duplicated.
      expect(state().messages.where((m) => m.isFromUser), hasLength(1));
    });

    test('a retry keeps the photos that were on that question', () async {
      await chat().attach(AiPhotoSource.gallery);
      service.answers.add(const Err(ServiceUnavailable()));
      await chat().send('Look', languageCode: 'en');
      expect(state().pendingPhotos, hasLength(1));
      await chat().retry(languageCode: 'en');
      expect(service.asked.last.photos, 1);
    });

    test('a daily limit is reported as such', () async {
      service.answers.add(const Err(RateLimited()));
      await chat().send('Hello', languageCode: 'en');
      expect(state().failure, const RateLimited());
    });

    test('a missing permission turns consent off again', () async {
      service.answers.add(const Err(ConsentMissing()));
      await chat().send('Hello', languageCode: 'en');
      expect(c.read(aiConsentStateProvider), isFalse);
    });

    test('Dismissing the failure removes the message', () async {
      service.answers.add(const Err(NetworkFailure()));
      await chat().send('Hello', languageCode: 'en');
      chat().dismissFailure();
      expect(state().failure, isNull);
    });
  });

  group('reporting an answer', () {
    Future<AiMessage> reply() async {
      await chat().send('Hi', languageCode: 'en');
      return state().messages.last;
    }

    test('is sent with the reason and the answer is marked', () async {
      final answer = await reply();
      final ok = await chat().report(answer, 'harmful');
      expect(ok, isTrue);
      expect(service.reports.single, (id: answer.id, reason: 'harmful'));
      expect(state().messages.last.reported, isTrue);
    });

    test('a failed report is not marked and says so', () async {
      service.reportResult = const Err(NetworkFailure());
      final answer = await reply();
      final ok = await chat().report(answer, 'wrong');
      expect(ok, isFalse);
      expect(state().messages.last.reported, isFalse);
    });

    test('an answer is only reported once', () async {
      final answer = await reply();
      await chat().report(answer, 'harmful');
      await chat().report(state().messages.last, 'harmful');
      expect(service.reports, hasLength(1));
    });
  });

  test('a new chat starts clean', () async {
    await chat().attach(AiPhotoSource.gallery);
    await chat().send('Hi', languageCode: 'en');
    chat().clear();
    expect(state().messages, isEmpty);
    expect(state().pendingPhotos, isEmpty);
    expect(state().failure, isNull);
  });

  group('progress review (the user chose to send their photos)', () {
    Uint8List photo(int n) => Uint8List.fromList([n, n, n]);

    test(
      'puts the photos and the question in the chat and sends them',
      () async {
        final ok = await chat().reviewProgress(
          photos: [photo(1), photo(2), photo(3)],
          question: 'Please compare my photos.',
          languageCode: 'en',
        );
        expect(ok, isTrue);
        expect(service.asked.single.photos, 3);
        expect(service.asked.single.question, 'Please compare my photos.');
        expect(state().messages.first.photoCount, 3);
        expect(state().messages.last.role, AiRole.assistant);
        expect(state().pendingPhotos, isEmpty);
      },
    );

    test('at most three photos go', () async {
      await chat().reviewProgress(
        photos: [photo(1), photo(2), photo(3), photo(4)],
        question: 'Compare',
        languageCode: 'en',
      );
      expect(service.asked.single.photos, 3);
    });

    test('photos already waiting in the chat are replaced', () async {
      await chat().attach(AiPhotoSource.gallery);
      await chat().reviewProgress(
        photos: [photo(1)],
        question: 'Compare',
        languageCode: 'en',
      );
      expect(service.asked.single.photos, 1);
    });

    test('without permission nothing is sent', () async {
      await c.read(aiConsentStateProvider.notifier).withdraw();
      final ok = await chat().reviewProgress(
        photos: [photo(1)],
        question: 'Compare',
        languageCode: 'en',
      );
      expect(ok, isFalse);
      expect(service.asked, isEmpty);
    });

    test('with no photos there is nothing to review', () async {
      final ok = await chat().reviewProgress(
        photos: const [],
        question: 'Compare',
        languageCode: 'en',
      );
      expect(ok, isFalse);
      expect(service.asked, isEmpty);
    });

    test('if it fails, Try again keeps the photos', () async {
      service.answers.add(const Err(NetworkFailure()));
      await chat().reviewProgress(
        photos: [photo(1), photo(2)],
        question: 'Compare',
        languageCode: 'en',
      );
      expect(state().failure, const NetworkFailure());
      await chat().retry(languageCode: 'en');
      expect(service.asked.last.photos, 2);
      expect(state().failure, isNull);
    });
  });
}
