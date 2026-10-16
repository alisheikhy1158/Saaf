import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/ingredient_clash.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';

/// Finds which products in the user's routine a [candidate] should not be
/// layered with. A clash only counts when both would be used at the same time
/// of day. Each clashing product is reported once.
class FindIngredientClashes {
  const FindIngredientClashes();

  List<IngredientClash> call(Product candidate, Routine routine) {
    final found = <IngredientClash>[];
    final seen = <(ClashRule, String)>{};

    for (final time in RoutineTime.values) {
      if (!candidate.times.contains(time)) continue;
      for (final step in routine.stepsFor(time)) {
        final other = step.product;
        if (other == candidate) continue;
        final rule = _ruleBetween(candidate, other);
        if (rule == null || !seen.add((rule, other.id))) continue;
        found.add(
          IngredientClash(
            rule: rule,
            withProduct: other,
            time: time,
            canMoveToOtherTime: _canMove(candidate, routine, time),
          ),
        );
      }
    }
    return found;
  }

  /// The candidate could be used at the other time of day with no clash there.
  bool _canMove(Product candidate, Routine routine, RoutineTime from) {
    final to = from == RoutineTime.morning
        ? RoutineTime.night
        : RoutineTime.morning;
    if (!candidate.times.contains(to)) return false;
    return routine
        .stepsFor(to)
        .every(
          (s) =>
              s.product == candidate ||
              _ruleBetween(candidate, s.product) == null,
        );
  }

  static bool _pair(
    Product a,
    Product b,
    bool Function(Set<Ingredient>) first,
    bool Function(Set<Ingredient>) second,
  ) =>
      (first(a.ingredients) && second(b.ingredients)) ||
      (first(b.ingredients) && second(a.ingredients));

  static ClashRule? _ruleBetween(Product a, Product b) {
    if (_pair(
      a,
      b,
      (i) => i.contains(Ingredient.niacinamide),
      (i) => i.contains(Ingredient.vitaminC),
    )) {
      return ClashRule.niacinamideAndVitaminC;
    }
    if (_pair(
      a,
      b,
      (i) => i.contains(Ingredient.retinol),
      (i) => i.any((x) => x.isExfoliant),
    )) {
      return ClashRule.retinolAndExfoliants;
    }
    if (_pair(
      a,
      b,
      (i) => i.contains(Ingredient.retinol),
      (i) => i.contains(Ingredient.benzoylPeroxide),
    )) {
      return ClashRule.benzoylPeroxideAndRetinol;
    }
    return null;
  }
}
