import 'dart:typed_data';

/// What the user gives Saaf AI to check a cream with.
sealed class CreamQuery {
  const CreamQuery();
}

/// A photo of the label (with its ingredient list if there is one).
final class CreamPhotoQuery extends CreamQuery {
  const CreamPhotoQuery(this.bytes);
  final Uint8List bytes;
}

/// The product's name, as the user typed it.
final class CreamNameQuery extends CreamQuery {
  const CreamNameQuery(this.name);
  final String name;

  @override
  bool operator ==(Object other) =>
      other is CreamNameQuery && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// The verdict. There is deliberately no "safe": a product nobody has
/// reported can still be harmful.
enum SafetyLevel { danger, caution, noKnownProblem }

/// What the phone's fixed rules found in a printed ingredient list.
enum IngredientRisk {
  /// Mercury in any form: damages skin, kidneys and nerves.
  mercury,

  /// A bleaching agent; prescription-only in many countries.
  hydroquinone,

  /// Strong steroid (clobetasol, betamethasone…): thins skin, causes rebound.
  strongSteroid,

  /// Milder steroid (hydrocortisone): not for daily face use without a doctor.
  steroid,

  /// Prescription retinoid (tretinoin, tazarotene).
  prescriptionRetinoid;

  /// The verdict this risk alone leads to.
  SafetyLevel get level => switch (this) {
    mercury || hydroquinone || strongSteroid => SafetyLevel.danger,
    steroid || prescriptionRetinoid => SafetyLevel.caution,
  };
}

class IngredientFlag {
  const IngredientFlag({required this.risk, required this.ingredient});

  final IngredientRisk risk;

  /// As printed on the label.
  final String ingredient;
}

/// One thing Saaf AI found, with the page it came from (null for a label fact).
class SafetyFinding {
  const SafetyFinding({required this.text, this.source});

  final String text;
  final String? source;
}

/// The result of checking a cream.
class SafetyCheck {
  const SafetyCheck({
    required this.found,
    this.title = '',
    this.level = SafetyLevel.caution,
    this.summary = '',
    this.ingredients = const [],
    this.ingredientsPrinted,
    this.findings = const [],
    this.flags = const [],
  });

  /// False when Saaf AI could not tell which product it is.
  final bool found;
  final String title;
  final SafetyLevel level;
  final String summary;

  /// Read from the label photo (empty without a photo).
  final List<String> ingredients;

  /// Whether the pack prints an ingredient list (null when not known).
  final bool? ingredientsPrinted;
  final List<SafetyFinding> findings;

  /// Added on the phone by the fixed rules.
  final List<IngredientFlag> flags;

  SafetyCheck copyWith({SafetyLevel? level, List<IngredientFlag>? flags}) =>
      SafetyCheck(
        found: found,
        title: title,
        level: level ?? this.level,
        summary: summary,
        ingredients: ingredients,
        ingredientsPrinted: ingredientsPrinted,
        findings: findings,
        flags: flags ?? this.flags,
      );
}
