// Covers: the 5-step skin quiz (docs/design.md §10 05 + the steps designed from
// research: skin type, concerns, sensitivity, safety, budget), SEC-8 (validate at
// the boundary), architecture §3.10 (Result, no throws)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/quiz_step.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';
import 'package:saaf/domain/usecases/save_quiz_answers.dart';

class FakeSkinProfileRepository implements SkinProfileRepository {
  SkinProfile? saved;
  int saveCalls = 0;
  Object? throwOnSave;

  @override
  Future<SkinProfile?> current() async => saved;

  @override
  Future<void> save(SkinProfile profile) async {
    saveCalls++;
    if (throwOnSave != null) throw throwOnSave!;
    saved = profile;
  }

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  late FakeSkinProfileRepository repository;
  late SaveQuizAnswers save;

  setUp(() {
    repository = FakeSkinProfileRepository();
    save = SaveQuizAnswers(repository);
  });

  group('the quiz has five steps in a fixed order', () {
    test('QuizStep', () {
      expect(QuizStep.values.map((s) => s.name), [
        'skinType',
        'concerns',
        'sensitivity',
        'safety',
        'budget',
      ]);
      expect(QuizStep.values.map((s) => s.number), [1, 2, 3, 4, 5]);
      expect(QuizStep.count, 5);
    });

    test('Figma option order is kept', () {
      expect(SkinConcern.values.map((c) => c.name), [
        'darkSpots',
        'acne',
        'oiliness',
        'dryness',
        'unevenTone',
        // Added after Figma, at the end (owner's request, 2026-10-18).
        'bodyPigmentation',
      ]);
      expect(SkinType.values.map((t) => t.name), [
        'oily',
        'dry',
        'combination',
        'normal',
        'notSure',
      ]);
    });

    test('QuizStep.fromNumber clamps to 1–5', () {
      expect(QuizStep.fromNumber(0), QuizStep.skinType);
      expect(QuizStep.fromNumber(3), QuizStep.sensitivity);
      expect(QuizStep.fromNumber(99), QuizStep.budget);
    });
  });

  group('skin type', () {
    test('saves exactly one', () async {
      final result = await save.skinType(SkinType.combination);
      expect(result.isOk, isTrue);
      expect(repository.saved?.skinType, SkinType.combination);
    });
  });

  group('concerns (pick up to two)', () {
    test('saves one or two', () async {
      expect((await save.concerns({SkinConcern.acne})).isOk, isTrue);
      final two = await save.concerns({
        SkinConcern.darkSpots,
        SkinConcern.oiliness,
      });
      expect(two.valueOrNull?.concerns.length, 2);
    });

    test('rejects three without saving', () async {
      final result = await save.concerns({
        SkinConcern.darkSpots,
        SkinConcern.acne,
        SkinConcern.dryness,
      });
      expect(result.failureOrNull, const ValidationFailure('concerns'));
      expect(repository.saveCalls, 0);
    });

    test('rejects an empty selection without saving', () async {
      final result = await save.concerns({});
      expect(result.failureOrNull, const ValidationFailure('concerns'));
      expect(repository.saveCalls, 0);
    });

    test('maxConcerns is two', () {
      expect(SaveQuizAnswers.maxConcerns, 2);
    });
  });

  group('sensitivity', () {
    test('saves exactly one level', () async {
      await save.sensitivity(Sensitivity.high);
      expect(repository.saved?.sensitivity, Sensitivity.high);
    });
  });

  group('safety flags', () {
    test('an empty set is a real answer: "none of these"', () async {
      final result = await save.safety({});
      expect(result.isOk, isTrue);
      expect(repository.saved?.safetyFlags, isEmpty);
      expect(repository.saved?.safetyFlags, isNotNull);
    });

    test('saves any combination', () async {
      await save.safety({
        SafetyFlag.pregnantOrBreastfeeding,
        SafetyFlag.ingredientAllergy,
      });
      expect(repository.saved?.safetyFlags, {
        SafetyFlag.pregnantOrBreastfeeding,
        SafetyFlag.ingredientAllergy,
      });
    });

    test('before the step is answered the flags are null (unknown)', () {
      expect(const SkinProfile().safetyFlags, isNull);
    });
  });

  group('budget', () {
    test('saves one band', () async {
      await save.budget(BudgetBand.balanced);
      expect(repository.saved?.budget, BudgetBand.balanced);
    });

    test(
      'bands carry their monthly ceiling in PKR for the routine builder',
      () {
        expect(BudgetBand.essential.maxMonthlyPkr, 3000);
        expect(BudgetBand.balanced.maxMonthlyPkr, 6000);
        expect(BudgetBand.comfortable.maxMonthlyPkr, 10000);
        expect(BudgetBand.premium.maxMonthlyPkr, isNull);
      },
    );
  });

  group('answers accumulate', () {
    test('each step keeps what the earlier steps saved', () async {
      await save.skinType(SkinType.oily);
      await save.concerns({SkinConcern.acne});
      await save.sensitivity(Sensitivity.sometimes);
      await save.safety({SafetyFlag.prescriptionTreatment});
      final last = await save.budget(BudgetBand.essential);

      expect(
        last.valueOrNull,
        const SkinProfile(
          skinType: SkinType.oily,
          concerns: {SkinConcern.acne},
          sensitivity: Sensitivity.sometimes,
          safetyFlags: {SafetyFlag.prescriptionTreatment},
          budget: BudgetBand.essential,
        ),
      );
    });

    test('changing one step leaves the others alone', () async {
      await save.skinType(SkinType.dry);
      await save.budget(BudgetBand.premium);
      await save.skinType(SkinType.oily);
      expect(repository.saved?.budget, BudgetBand.premium);
      expect(repository.saved?.skinType, SkinType.oily);
    });
  });

  group('storage', () {
    test('a storage error becomes StorageFailure, not an exception', () async {
      repository.throwOnSave = StateError('disk full');
      expect(
        (await save.skinType(SkinType.dry)).failureOrNull,
        const StorageFailure(),
      );
      expect(
        (await save.concerns({SkinConcern.acne})).failureOrNull,
        const StorageFailure(),
      );
      expect(
        (await save.sensitivity(Sensitivity.high)).failureOrNull,
        const StorageFailure(),
      );
      expect((await save.safety({})).failureOrNull, const StorageFailure());
      expect(
        (await save.budget(BudgetBand.premium)).failureOrNull,
        const StorageFailure(),
      );
    });
  });

  test('SkinProfile has value equality', () {
    expect(
      const SkinProfile(concerns: {SkinConcern.acne}),
      const SkinProfile(concerns: {SkinConcern.acne}),
    );
  });
}
