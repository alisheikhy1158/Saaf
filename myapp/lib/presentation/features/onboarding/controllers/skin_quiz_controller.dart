import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/quiz_step.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/onboarding/quiz/quiz_step_views.dart';
import 'package:saaf/presentation/features/onboarding/state/skin_quiz_state.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'skin_quiz_controller.g.dart';

/// The answers of one quiz [step]: toggling options and saving them.
@riverpod
class SkinQuizController extends _$SkinQuizController {
  @override
  SkinQuizState build(QuizStep step) {
    // Re-open the step with the answer saved earlier.
    final profile = ref.read(skinProfileControllerProvider);
    return SkinQuizState(selected: _savedAnswer(step, profile));
  }

  static List<Enum> _savedAnswer(QuizStep step, SkinProfile profile) =>
      switch (step) {
        QuizStep.skinType => [?profile.skinType],
        QuizStep.concerns => profile.concerns.toList(),
        QuizStep.sensitivity => [?profile.sensitivity],
        QuizStep.safety => switch (profile.safetyFlags) {
          null => <Enum>[],
          final flags when flags.isEmpty => <Enum>[SafetyChoice.none],
          final flags => [for (final flag in flags) _choiceFor(flag)],
        },
        QuizStep.budget => [?profile.budget],
      };

  static SafetyChoice _choiceFor(SafetyFlag flag) => switch (flag) {
    SafetyFlag.pregnantOrBreastfeeding => SafetyChoice.pregnantOrBreastfeeding,
    SafetyFlag.prescriptionTreatment => SafetyChoice.prescriptionTreatment,
    SafetyFlag.ingredientAllergy => SafetyChoice.ingredientAllergy,
  };

  static SafetyFlag? _flagFor(Enum choice) => switch (choice) {
    SafetyChoice.pregnantOrBreastfeeding => SafetyFlag.pregnantOrBreastfeeding,
    SafetyChoice.prescriptionTreatment => SafetyFlag.prescriptionTreatment,
    SafetyChoice.ingredientAllergy => SafetyFlag.ingredientAllergy,
    _ => null,
  };

  /// Chooses or unchooses [option]. Single-choice steps switch to it; the
  /// concerns step keeps at most two (a third drops the earliest); on the
  /// safety step "None of these" and the flags exclude each other.
  void toggle(Enum option) {
    final view = quizStepViews[step]!;
    var selected = [...state.selected];

    if (view.isSingleChoice) {
      selected = [option];
    } else if (selected.remove(option)) {
      // Unchosen.
    } else {
      if (option == view.exclusive) {
        selected.clear();
      } else if (view.exclusive != null) {
        selected.remove(view.exclusive);
      }
      selected.add(option);
      final max = view.maxSelected;
      while (max != null && selected.length > max) {
        selected.removeAt(0);
      }
    }
    state = state.copyWith(selected: selected, failure: null);
  }

  /// Saves this step's answer. True when it was saved.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, failure: null);

    final save = ref.read(saveQuizAnswersProvider);
    final chosen = state.selected;
    final Result<SkinProfile> result = switch (step) {
      QuizStep.skinType => await save.skinType(chosen.single as SkinType),
      QuizStep.concerns => await save.concerns(
        chosen.cast<SkinConcern>().toSet(),
      ),
      QuizStep.sensitivity => await save.sensitivity(
        chosen.single as Sensitivity,
      ),
      QuizStep.safety => await save.safety({
        for (final choice in chosen) ?_flagFor(choice),
      }),
      QuizStep.budget => await save.budget(chosen.single as BudgetBand),
    };

    final profile = result.valueOrNull;
    if (profile != null) {
      ref.read(skinProfileControllerProvider.notifier).set(profile);
    }
    state = state.copyWith(isSubmitting: false, failure: result.failureOrNull);
    return profile != null;
  }
}
