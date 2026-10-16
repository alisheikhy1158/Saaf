import 'package:saaf/domain/entities/product.dart';

/// Ingredient pairs that are best not used together (advice, never a diagnosis).
enum ClashRule {
  /// Niacinamide with vitamin C: use them at different times of day.
  niacinamideAndVitaminC,

  /// A retinoid with an exfoliating acid: more irritation.
  retinolAndExfoliants,

  /// A retinoid with benzoyl peroxide: more irritation.
  benzoylPeroxideAndRetinol,
}

/// A scanned product clashes with [withProduct], which the user's routine uses
/// at [time].
class IngredientClash {
  const IngredientClash({
    required this.rule,
    required this.withProduct,
    required this.time,
    required this.canMoveToOtherTime,
  });

  final ClashRule rule;
  final Product withProduct;
  final RoutineTime time;

  /// The scanned product can be used at the other time of day without a clash,
  /// so "use it at night instead" is real advice.
  final bool canMoveToOtherTime;
}
