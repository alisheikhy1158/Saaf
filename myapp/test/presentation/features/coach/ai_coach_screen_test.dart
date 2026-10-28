// Covers: the AI coach screen — consent first with who receives the data
// (Apple 5.1.2(i)), the chat, photos, a visible report button (Play AI policy)
// and kind error messages
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/domain/services/voice_input.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/presentation/features/coach/screens/ai_coach_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _Service implements AiCoachService {
  final List<Result<String>> answers = [];
  final List<({String question, int photos})> asked = [];
  final List<String> reports = [];
  Result<void> reportResult = const Ok(null);

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async {
    asked.add((question: question, photos: photos.length));
    return answers.isEmpty
        ? const Ok('Use a gentle cleanser twice a day.')
        : answers.removeAt(0);
  }

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async {
    reports.add(reason);
    return reportResult;
  }
}

class _Picker implements AiPhotoPicker {
  Result<Uint8List?> next = Ok(
    solidPng(width: 24, height: 32, red: 184, green: 156, blue: 132),
  );

  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async => next;
}

class _Voice implements VoiceInput {
  final List<String> languages = [];
  bool listening = false;

  @override
  Future<bool> start({
    required String languageCode,
    required void Function(String words, bool done) onWords,
  }) async {
    languages.add(languageCode);
    listening = true;
    onWords('Is my routine', false);
    onWords('Is my routine right for me', true);
    return true;
  }

  @override
  Future<void> stop() async => listening = false;
}

late _Service _service;
late _Picker _picker;
late _Voice _voice;

List<Override> _overrides({bool consented = true}) {
  final settings = InMemorySettingsRepository();
  if (consented) {
    settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 17).toIso8601String(),
    );
  }
  return [
    aiCoachServiceProvider.overrideWithValue(_service),
    aiPhotoPickerProvider.overrideWithValue(_picker),
    settingsRepositoryProvider.overrideWithValue(settings),
    voiceInputProvider.overrideWithValue(_voice),
  ];
}

Future<void> _open(
  WidgetTester tester, {
  bool consented = true,
  Size size = const Size(390, 844),
}) async {
  await pumpSaafApp(
    tester,
    location: '/ai-coach',
    size: size,
    overrides: _overrides(consented: consented),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const ValueKey('ai-input')), text);
  await tester.pump();
  await _tap(tester, find.byKey(const ValueKey('ai-send')));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUp(() {
    _service = _Service();
    _picker = _Picker();
    _voice = _Voice();
  });

  testWidgets('opened to turn Saaf AI on elsewhere: agreeing goes back', (
    tester,
  ) async {
    await pumpSaafApp(
      tester,
      location: '/ai-coach?return=1',
      overrides: _overrides(consented: false),
    );
    await tester.pump();
    await tester.pump();
    await _tap(tester, find.text('I agree, start chatting'));
    await tester.pump(const Duration(seconds: 1));
    // Nothing to go back to in this test, so Home.
    expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
  });

  group('before the first chat', () {
    testWidgets('explains what is sent and who receives it, then asks', (
      tester,
    ) async {
      await _open(tester, consented: false);
      expect(find.text('Before you chat with the AI coach'), findsOneWidget);
      expect(find.text('What is sent'), findsOneWidget);
      expect(find.textContaining('Never your name'), findsOneWidget);
      expect(find.text('Who receives it'), findsOneWidget);
      expect(find.textContaining('Groq'), findsOneWidget);
      expect(find.text('I agree, start chatting'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      // No chat box and nothing sent yet.
      expect(find.byKey(const ValueKey('ai-input')), findsNothing);
      expect(_service.asked, isEmpty);
    });

    testWidgets('agreeing opens the chat', (tester) async {
      await _open(tester, consented: false);
      await _tap(tester, find.text('I agree, start chatting'));
      expect(find.byKey(const ValueKey('ai-input')), findsOneWidget);
    });

    testWidgets('"Not now" leaves without agreeing', (tester) async {
      await _open(tester, consented: false);
      await _tap(tester, find.text('Not now'));
      expect(find.byKey(const ValueKey('screen-aiCoach')), findsNothing);
    });

    testWidgets('links to the Privacy Policy', (tester) async {
      await _open(tester, consented: false);
      expect(find.text('Read the Privacy Policy'), findsOneWidget);
    });
  });

  group('the chat', () {
    testWidgets('always says AI can be wrong and is not medical advice', (
      tester,
    ) async {
      await _open(tester);
      expect(find.textContaining('not medical advice'), findsOneWidget);
      expect(find.textContaining('dermatologist'), findsOneWidget);
    });

    testWidgets('starts with a few things to ask', (tester) async {
      await _open(tester);
      expect(find.text('Is my routine right for me?'), findsOneWidget);
      expect(find.text('How do I choose a sunscreen?'), findsOneWidget);
    });

    testWidgets('tapping a suggestion asks it', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('Is my routine right for me?'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_service.asked.single.question, 'Is my routine right for me?');
      expect(find.text('Use a gentle cleanser twice a day.'), findsOneWidget);
    });

    testWidgets('a typed question and the answer appear as bubbles', (
      tester,
    ) async {
      await _open(tester);
      await _ask(tester, 'Can I use retinol every night?');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Can I use retinol every night?'), findsOneWidget);
      expect(find.text('Use a gentle cleanser twice a day.'), findsOneWidget);
      expect(find.text('AI answer'), findsOneWidget);
    });

    testWidgets('the box is emptied after sending and the suggestions go', (
      tester,
    ) async {
      await _open(tester);
      await _ask(tester, 'Hello');
      await tester.pump(const Duration(milliseconds: 100));
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('ai-input')),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller!.text, isEmpty);
      expect(find.text('Is my routine right for me?'), findsNothing);
    });

    testWidgets('sending needs some words or a photo', (tester) async {
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('ai-send')));
      expect(_service.asked, isEmpty);
    });
  });

  group('a long answer is tidy', () {
    testWidgets('headings, bullets and bold instead of ** and tables', (
      tester,
    ) async {
      _service.answers.add(
        const Ok(
          'Your routine covers the basics.\n\n'
          '**What’s working well**\n'
          '- **Neem face wash** – good for oily skin.\n\n'
          '| Step | Product | Tweak |\n'
          '|---|---|---|\n'
          '| Moisturiser | Nivea Soft | Try a gel |',
        ),
      );
      await _open(tester);
      await _ask(tester, 'Is my routine right for me?');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('What’s working well'), findsOneWidget);
      expect(find.textContaining('Neem face wash'), findsOneWidget);
      expect(find.textContaining('Nivea Soft · Try a gel'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('|'), findsNothing);
    });
  });

  group('reporting an answer', () {
    Future<void> answered(WidgetTester tester) async {
      await _open(tester);
      await _ask(tester, 'Hello');
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('every answer has a report button', (tester) async {
      await answered(tester);
      expect(find.byTooltip('Report this answer'), findsOneWidget);
    });

    testWidgets('choosing a reason sends it and says thank you', (
      tester,
    ) async {
      await answered(tester);
      await _tap(tester, find.byTooltip('Report this answer'));
      expect(find.text('What is wrong with this answer?'), findsOneWidget);
      await _tap(tester, find.text('Harmful or unsafe'));
      expect(_service.reports, ['harmful']);
      expect(
        find.text('Thank you. We will review this answer.'),
        findsOneWidget,
      );
      expect(find.text('Reported'), findsOneWidget);
    });

    testWidgets('a report that cannot be sent says so and can be retried', (
      tester,
    ) async {
      _service.reportResult = const Err(NetworkFailure());
      await answered(tester);
      await _tap(tester, find.byTooltip('Report this answer'));
      await _tap(tester, find.text('Wrong or misleading'));
      expect(
        find.text('We couldn’t send your report. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Reported'), findsNothing);
    });
  });

  group('speaking instead of typing', () {
    testWidgets('explains first, then the words go into the message box', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.byTooltip('Speak your question'));
      expect(find.text('Speak instead of typing'), findsOneWidget);
      expect(find.textContaining('speech service'), findsOneWidget);
      expect(_voice.languages, isEmpty);
      await _tap(tester, find.text('Continue'));
      expect(_voice.languages, ['en']);
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('ai-input')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text, 'Is my routine right for me');
      // Nothing is sent until the user taps send.
      expect(_service.asked, isEmpty);
    });

    testWidgets('Not now does not listen', (tester) async {
      await _open(tester);
      await _tap(tester, find.byTooltip('Speak your question'));
      await _tap(tester, find.text('Not now'));
      expect(_voice.languages, isEmpty);
    });
  });

  group('photos', () {
    testWidgets('attach, see it, remove it', (tester) async {
      await _open(tester);
      await _tap(tester, find.byTooltip('Attach a photo'));
      expect(find.text('Take a photo'), findsOneWidget);
      await _tap(tester, find.text('Choose from gallery'));
      expect(find.byKey(const ValueKey('ai-photo-0')), findsOneWidget);
      await _tap(tester, find.byTooltip('Remove photo'));
      expect(find.byKey(const ValueKey('ai-photo-0')), findsNothing);
    });

    testWidgets('a photo alone can be sent', (tester) async {
      await _open(tester);
      await _tap(tester, find.byTooltip('Attach a photo'));
      await _tap(tester, find.text('Take a photo'));
      await _tap(tester, find.byKey(const ValueKey('ai-send')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_service.asked.single.photos, 1);
      expect(find.text('Use a gentle cleanser twice a day.'), findsOneWidget);
    });

    testWidgets('a photo that cannot be got says so', (tester) async {
      _picker.next = const Err(UnknownFailure('x'));
      await _open(tester);
      await _tap(tester, find.byTooltip('Attach a photo'));
      await _tap(tester, find.text('Choose from gallery'));
      expect(
        find.text('We couldn’t get that photo. Please try again.'),
        findsOneWidget,
      );
    });
  });

  group('when it goes wrong', () {
    for (final (failure, text) in [
      (
        const NetworkFailure(),
        'No connection. Check your internet and try again.',
      ),
      (
        const RateLimited(),
        'You’ve reached today’s limit. Please try again tomorrow.',
      ),
      (
        const ServiceUnavailable(),
        'The AI coach isn’t available right now. Please try again later.',
      ),
      (const Unauthorised(), 'Please sign in again to use the AI coach.'),
      (const UnknownFailure('x'), 'Something went wrong. Please try again.'),
    ]) {
      testWidgets('$failure is explained kindly', (tester) async {
        _service.answers.add(Err(failure));
        await _open(tester);
        await _ask(tester, 'Hello');
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets('Try again sends it again and shows the answer', (
      tester,
    ) async {
      _service.answers.add(const Err(NetworkFailure()));
      await _open(tester);
      await _ask(tester, 'Hello');
      await tester.pump(const Duration(milliseconds: 100));
      await _tap(tester, find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Use a gentle cleanser twice a day.'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('the menu', () {
    testWidgets(
      'stopping the sharing wipes the chat and asks again next time',
      (tester) async {
        await _open(tester);
        await _ask(tester, 'Hello');
        await tester.pump(const Duration(milliseconds: 100));
        await _tap(tester, find.byTooltip('More'));
        await _tap(tester, find.text('Stop sharing with AI'));
        expect(find.text('Before you chat with the AI coach'), findsOneWidget);
        expect(find.text('Hello'), findsNothing);
      },
    );

    testWidgets('a new chat starts clean', (tester) async {
      await _open(tester);
      await _ask(tester, 'Hello');
      await tester.pump(const Duration(milliseconds: 100));
      await _tap(tester, find.byTooltip('More'));
      await _tap(tester, find.text('New chat'));
      expect(find.text('Hello'), findsNothing);
      expect(find.text('Is my routine right for me?'), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('consent and chat are robust at every size', (tester) async {
      for (final size in matrixSizes) {
        await _open(tester, consented: false, size: size);
        expect(tester.takeException(), isNull, reason: '$size consent');
        // A fresh app (and so a fresh saved permission) for the chat.
        await tester.pumpWidget(const SizedBox());
        await _open(tester, size: size);
        await _ask(tester, 'Hello');
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$size chat');
      }
    });

    testWidgets('Urdu at 200 % text fits', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpSaaf(
        tester,
        const AiCoachScreen(),
        scaffold: false,
        textScale: 2,
        locale: const Locale('ur'),
        overrides: _overrides(),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('buttons are big enough and labelled', (tester) async {
      await _open(tester);
      await _ask(tester, 'Hello');
      await tester.pump(const Duration(milliseconds: 100));
      await expectTapTargetsAccessible(tester);
    });
  });
}
