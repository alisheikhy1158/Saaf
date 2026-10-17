import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/quiz_step.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/save_quiz_answers.dart';

/// Safety options as shown: the three flags plus "None of these", which is an
/// answer of its own (saved as an empty set).
enum SafetyChoice {
  pregnantOrBreastfeeding,
  prescriptionTreatment,
  ingredientAllergy,
  none,
}

typedef Localized = String Function(AppLocalizations l10n);

/// One option of a quiz step. [value] is a domain enum (or [SafetyChoice]).
class QuizOptionView {
  const QuizOptionView(this.value, this.icon, this.title, this.caption);

  final Enum value;
  final IconData icon;
  final Localized title;
  final Localized caption;
}

/// How one quiz step looks and how many answers it takes.
class QuizStepView {
  const QuizStepView({
    required this.title,
    required this.hint,
    required this.options,
    this.maxSelected,
    this.exclusive,
  });

  final Localized title;
  final Localized hint;
  final List<QuizOptionView> options;

  /// How many options may be chosen at once; null means any number.
  final int? maxSelected;

  /// An option that excludes all the others (safety: "None of these").
  final Enum? exclusive;

  bool get isSingleChoice => maxSelected == 1;
}

/// Presentation of the five steps (copy lives in the ARB files).
final Map<QuizStep, QuizStepView> quizStepViews = {
  QuizStep.skinType: QuizStepView(
    title: (l) => l.quizSkinTypeTitle,
    hint: (l) => l.quizSkinTypeHint,
    maxSelected: 1,
    options: [
      QuizOptionView(
        SkinType.oily,
        Icons.water_drop_outlined,
        (l) => l.skinTypeOilyTitle,
        (l) => l.skinTypeOilyCaption,
      ),
      QuizOptionView(
        SkinType.dry,
        Icons.wb_sunny_outlined,
        (l) => l.skinTypeDryTitle,
        (l) => l.skinTypeDryCaption,
      ),
      QuizOptionView(
        SkinType.combination,
        Icons.contrast,
        (l) => l.skinTypeCombinationTitle,
        (l) => l.skinTypeCombinationCaption,
      ),
      QuizOptionView(
        SkinType.normal,
        Icons.spa_outlined,
        (l) => l.skinTypeNormalTitle,
        (l) => l.skinTypeNormalCaption,
      ),
      QuizOptionView(
        SkinType.notSure,
        Icons.help_outline,
        (l) => l.skinTypeNotSureTitle,
        (l) => l.skinTypeNotSureCaption,
      ),
    ],
  ),
  QuizStep.concerns: QuizStepView(
    title: (l) => l.quizConcernsTitle,
    hint: (l) => l.quizConcernsHint,
    maxSelected: SaveQuizAnswers.maxConcerns,
    options: [
      QuizOptionView(
        SkinConcern.darkSpots,
        Icons.auto_awesome_outlined,
        (l) => l.concernDarkSpotsTitle,
        (l) => l.concernDarkSpotsCaption,
      ),
      QuizOptionView(
        SkinConcern.acne,
        Icons.adjust,
        (l) => l.concernAcneTitle,
        (l) => l.concernAcneCaption,
      ),
      QuizOptionView(
        SkinConcern.oiliness,
        Icons.water_drop_outlined,
        (l) => l.concernOilinessTitle,
        (l) => l.concernOilinessCaption,
      ),
      QuizOptionView(
        SkinConcern.dryness,
        Icons.wb_sunny_outlined,
        (l) => l.concernDrynessTitle,
        (l) => l.concernDrynessCaption,
      ),
      QuizOptionView(
        SkinConcern.unevenTone,
        Icons.layers_outlined,
        (l) => l.concernUnevenToneTitle,
        (l) => l.concernUnevenToneCaption,
      ),
      QuizOptionView(
        SkinConcern.bodyPigmentation,
        Icons.accessibility_new_outlined,
        (l) => l.concernBodyTitle,
        (l) => l.concernBodyCaption,
      ),
    ],
  ),
  QuizStep.sensitivity: QuizStepView(
    title: (l) => l.quizSensitivityTitle,
    hint: (l) => l.quizSensitivityHint,
    maxSelected: 1,
    options: [
      QuizOptionView(
        Sensitivity.low,
        Icons.sentiment_satisfied_alt_outlined,
        (l) => l.sensitivityLowTitle,
        (l) => l.sensitivityLowCaption,
      ),
      QuizOptionView(
        Sensitivity.sometimes,
        Icons.sentiment_neutral_outlined,
        (l) => l.sensitivitySometimesTitle,
        (l) => l.sensitivitySometimesCaption,
      ),
      QuizOptionView(
        Sensitivity.high,
        Icons.sentiment_dissatisfied_outlined,
        (l) => l.sensitivityHighTitle,
        (l) => l.sensitivityHighCaption,
      ),
    ],
  ),
  QuizStep.safety: QuizStepView(
    title: (l) => l.quizSafetyTitle,
    hint: (l) => l.quizSafetyHint,
    exclusive: SafetyChoice.none,
    options: [
      QuizOptionView(
        SafetyChoice.pregnantOrBreastfeeding,
        Icons.child_friendly_outlined,
        (l) => l.safetyPregnantTitle,
        (l) => l.safetyPregnantCaption,
      ),
      QuizOptionView(
        SafetyChoice.prescriptionTreatment,
        Icons.medical_services_outlined,
        (l) => l.safetyPrescriptionTitle,
        (l) => l.safetyPrescriptionCaption,
      ),
      QuizOptionView(
        SafetyChoice.ingredientAllergy,
        Icons.warning_amber_outlined,
        (l) => l.safetyAllergyTitle,
        (l) => l.safetyAllergyCaption,
      ),
      QuizOptionView(
        SafetyChoice.none,
        Icons.check_circle_outline,
        (l) => l.safetyNoneTitle,
        (l) => l.safetyNoneCaption,
      ),
    ],
  ),
  QuizStep.budget: QuizStepView(
    title: (l) => l.quizBudgetTitle,
    hint: (l) => l.quizBudgetHint,
    maxSelected: 1,
    options: [
      QuizOptionView(
        BudgetBand.essential,
        Icons.savings_outlined,
        (l) => l.budgetEssentialTitle,
        (l) => l.budgetEssentialCaption,
      ),
      QuizOptionView(
        BudgetBand.balanced,
        Icons.account_balance_wallet_outlined,
        (l) => l.budgetBalancedTitle,
        (l) => l.budgetBalancedCaption,
      ),
      QuizOptionView(
        BudgetBand.comfortable,
        Icons.shopping_bag_outlined,
        (l) => l.budgetComfortableTitle,
        (l) => l.budgetComfortableCaption,
      ),
      QuizOptionView(
        BudgetBand.premium,
        Icons.diamond_outlined,
        (l) => l.budgetPremiumTitle,
        (l) => l.budgetPremiumCaption,
      ),
    ],
  ),
};
