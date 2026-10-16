// Covers: the AI skin coach (store-compliance §5) — explicit consent before
// anything is sent, only non-health context goes to the AI, sensible limits
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/ask_coach.dart';

class _Service implements AiCoachService {
  Result<String> answer = const Ok('Use a gentle cleanser.');
  int calls = 0;
  List<AiMessage>? history;
  String? question;
  List<Uint8List>? photos;
  AiContext? context;

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async {
    calls++;
    this.history = history;
    this.question = question;
    this.photos = photos;
    this.context = context;
    return answer;
  }

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async => const Ok(null);
}

const _profile = SkinProfile(
  skinType: SkinType.combination,
  concerns: {SkinConcern.acne, SkinConcern.darkSpots},
  sensitivity: Sensitivity.sometimes,
  budget: BudgetBand.balanced,
);

const _routine = Routine(
  morning: [
    RoutineStep(
      number: 1,
      product: Product(
        id: 'a',
        name: 'Himalaya Purifying Neem Face Wash',
        category: ProductCategory.cleanser,
        pricePkr: 540,
        times: {RoutineTime.morning, RoutineTime.night},
      ),
    ),
  ],
  night: [
    RoutineStep(
      number: 1,
      product: Product(
        id: 'a',
        name: 'Himalaya Purifying Neem Face Wash',
        category: ProductCategory.cleanser,
        pricePkr: 540,
        times: {RoutineTime.morning, RoutineTime.night},
      ),
    ),
    RoutineStep(
      number: 2,
      product: Product(
        id: 'b',
        name: 'The Ordinary Retinol 0.5% in Squalane',
        category: ProductCategory.treatment,
        pricePkr: 5450,
        times: {RoutineTime.night},
      ),
    ),
  ],
);

Uint8List _photo() => Uint8List.fromList([1, 2, 3]);

void main() {
  late _Service service;
  late AiConsent consent;
  late AskCoach ask;

  setUp(() async {
    service = _Service();
    consent = AiConsent(
      InMemorySettingsRepository(),
      now: () => DateTime(2026, 10, 17),
    );
    await consent.give();
    ask = AskCoach(service: service, consent: consent);
  });

  Future<Result<String>> send(
    String text, {
    List<Uint8List>? photos,
    List<AiMessage> history = const [],
    SkinProfile profile = _profile,
    Routine? routine,
  }) => ask(
    text: text,
    photos: photos ?? const [],
    history: history,
    profile: profile,
    routine: routine ?? _routine,
    languageCode: 'en',
  );

  group('consent comes first', () {
    test('without it nothing is sent', () async {
      await consent.withdraw();
      final result = await send('Is my routine ok?');
      expect(result.failureOrNull, const ConsentMissing());
      expect(service.calls, 0);
    });

    test('with it the question goes through', () async {
      final result = await send('Is my routine ok?');
      expect(result.valueOrNull, 'Use a gentle cleanser.');
      expect(service.calls, 1);
      expect(service.question, 'Is my routine ok?');
    });

    test('consent is remembered and can be taken back', () async {
      expect(await consent.isGiven(), isTrue);
      await consent.withdraw();
      expect(await consent.isGiven(), isFalse);
    });
  });

  group('what the AI is told about the user', () {
    test(
      'skin type, concerns, sensitivity, budget and routine products',
      () async {
        await send('Hi');
        final c = service.context!;
        expect(c.skinType, SkinType.combination);
        expect(c.concerns, {SkinConcern.acne, SkinConcern.darkSpots});
        expect(c.sensitivity, Sensitivity.sometimes);
        expect(c.budget, BudgetBand.balanced);
        expect(c.languageCode, 'en');
        expect(c.routineProducts, [
          'Himalaya Purifying Neem Face Wash',
          'The Ordinary Retinol 0.5% in Squalane',
        ]);
      },
    );

    test('NEVER the safety answers (they stay on the phone)', () async {
      await send('Hi');
      final without = service.context!;
      await send(
        'Hi',
        profile: _profile.copyWith(
          safetyFlags: {
            SafetyFlag.pregnantOrBreastfeeding,
            SafetyFlag.prescriptionTreatment,
            SafetyFlag.ingredientAllergy,
          },
        ),
      );
      expect(service.context, without);
    });

    test('an empty profile and no routine still work', () async {
      final result = await send(
        'Hi',
        profile: const SkinProfile(),
        routine: const Routine(morning: [], night: []),
      );
      expect(result.isOk, isTrue);
      expect(service.context!.routineProducts, isEmpty);
      expect(service.context!.skinType, isNull);
    });
  });

  group('limits', () {
    test('an empty message with no photo is refused', () async {
      expect(
        (await send('   ')).failureOrNull,
        const ValidationFailure('message'),
      );
      expect(service.calls, 0);
    });

    test('a photo alone is a fine question', () async {
      final result = await send('', photos: [_photo()]);
      expect(result.isOk, isTrue);
      expect(service.photos, hasLength(1));
    });

    test('a very long message is refused', () async {
      final result = await send('a' * (AskCoach.maxTextLength + 1));
      expect(result.failureOrNull, const ValidationFailure('message'));
    });

    test('at most three photos', () async {
      final result = await send(
        'Look',
        photos: [_photo(), _photo(), _photo(), _photo()],
      );
      expect(result.failureOrNull, const ValidationFailure('photos'));
      expect(service.calls, 0);
    });

    test('the text is tidied', () async {
      await send('  Is   it   safe?  ');
      expect(service.question, 'Is it safe?');
    });

    test('only the latest part of a long chat is sent', () async {
      final history = [
        for (var i = 0; i < 30; i++)
          AiMessage(
            id: 'm$i',
            role: i.isEven ? AiRole.user : AiRole.assistant,
            text: 'message $i',
            createdAt: DateTime(2026, 10, 17),
          ),
      ];
      await send('Next', history: history);
      expect(service.history, hasLength(AskCoach.maxHistory));
      expect(service.history!.last.text, 'message 29');
    });
  });

  group('when the service fails', () {
    test('the failure is passed on', () async {
      service.answer = const Err(RateLimited());
      expect((await send('Hi')).failureOrNull, const RateLimited());
    });

    test('an unexpected error becomes a failure, not a crash', () async {
      final throwing = AskCoach(service: _Throwing(), consent: consent);
      final result = await throwing(
        text: 'Hi',
        photos: const [],
        history: const [],
        profile: _profile,
        routine: _routine,
        languageCode: 'en',
      );
      expect(result.isOk, isFalse);
    });
  });
}

class _Throwing implements AiCoachService {
  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async => throw StateError('boom');

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async => const Ok(null);
}
