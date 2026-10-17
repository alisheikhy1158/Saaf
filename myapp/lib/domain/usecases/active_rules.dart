import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';

/// What the app concludes from a product's active ingredients, on the phone.
/// Saaf AI only says WHICH actives a product from the web contains; these rules
/// (the same ones behind the app's own catalogue) decide whether it is strong
/// or best avoided in pregnancy, so the safety answers never have to leave the
/// phone. Simplified and conservative; due a dermatologist's review.
abstract final class ActiveRules {
  static const _strong = {
    Ingredient.retinol,
    Ingredient.vitaminC,
    Ingredient.salicylicAcid,
    Ingredient.benzoylPeroxide,
    Ingredient.aha,
  };

  static const _avoidInPregnancy = {
    Ingredient.retinol,
    Ingredient.salicylicAcid,
  };

  static const _helps = <Ingredient, Set<SkinConcern>>{
    Ingredient.niacinamide: {
      SkinConcern.oiliness,
      SkinConcern.darkSpots,
      SkinConcern.acne,
    },
    Ingredient.vitaminC: {SkinConcern.darkSpots, SkinConcern.unevenTone},
    Ingredient.retinol: {SkinConcern.acne, SkinConcern.darkSpots},
    Ingredient.salicylicAcid: {SkinConcern.acne, SkinConcern.oiliness},
    Ingredient.azelaicAcid: {
      SkinConcern.darkSpots,
      SkinConcern.unevenTone,
      SkinConcern.acne,
    },
    Ingredient.hyaluronicAcid: {SkinConcern.dryness},
    Ingredient.benzoylPeroxide: {SkinConcern.acne},
    Ingredient.zinc: {SkinConcern.oiliness, SkinConcern.acne},
    Ingredient.ceramides: {SkinConcern.dryness},
    Ingredient.aha: {SkinConcern.unevenTone, SkinConcern.darkSpots},
  };

  static bool isStrong(Set<Ingredient> actives) =>
      actives.any(_strong.contains);

  static bool avoidInPregnancy(Set<Ingredient> actives) =>
      actives.any(_avoidInPregnancy.contains);

  static Set<SkinConcern> helpsWith(Set<Ingredient> actives) => {
    for (final active in actives) ...?_helps[active],
  };

  /// A product found on the web, with its flags worked out from [actives].
  static Product product({
    required String id,
    required String name,
    required ProductCategory category,
    required int pricePkr,
    required Set<RoutineTime> times,
    required Set<Ingredient> actives,
    required bool fragranceFree,
  }) => Product(
    id: id,
    name: name,
    category: category,
    pricePkr: pricePkr,
    times: times,
    targets: helpsWith(actives),
    ingredients: actives,
    isStrongActive: isStrong(actives),
    avoidInPregnancy: avoidInPregnancy(actives),
    fragranceFree: fragranceFree,
  );
}
