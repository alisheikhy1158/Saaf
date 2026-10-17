import 'package:saaf/domain/entities/safety_check.dart';

/// Fixed rules for ingredients that must never be in an everyday cream:
/// mercury (in all its label names), hydroquinone, steroids and prescription
/// retinoids. Each risk is reported once, with the ingredient as printed.
/// Simplified and conservative; due a dermatologist's review.
class FlagIngredients {
  const FlagIngredients();

  static const _rules = <(IngredientRisk, List<String>)>[
    (
      IngredientRisk.mercury,
      [
        'mercur', // mercury, mercurous, mercuric
        'calomel',
        'hydrargyr',
        'quicksilver',
        'cinnabar',
      ],
    ),
    (IngredientRisk.hydroquinone, ['hydroquinone', 'hydroquinol']),
    (
      IngredientRisk.strongSteroid,
      [
        'clobetasol',
        'betamethasone',
        'dexamethasone',
        'mometasone',
        'fluocinolone',
        'fluocinonide',
        'halobetasol',
        'triamcinolone',
        'beclomethasone',
      ],
    ),
    (IngredientRisk.steroid, ['hydrocortisone', 'prednisolone']),
    (IngredientRisk.prescriptionRetinoid, ['tretinoin', 'tazarotene']),
  ];

  List<IngredientFlag> call(List<String> ingredients) {
    final flags = <IngredientFlag>[];
    for (final (risk, words) in _rules) {
      for (final ingredient in ingredients) {
        final lower = ingredient.toLowerCase();
        if (words.any(lower.contains)) {
          flags.add(IngredientFlag(risk: risk, ingredient: ingredient.trim()));
          break;
        }
      }
    }
    return flags;
  }
}
