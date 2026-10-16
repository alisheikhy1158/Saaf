// Covers: 10 Product scan result — ingredient clashes with the user's routine and
// how well a scanned product fits their skin (pure domain, PLAN Phase 8)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/ingredient_clash.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/assess_product.dart';
import 'package:saaf/domain/usecases/find_ingredient_clashes.dart';

Product product(
  String id, {
  Set<Ingredient> ingredients = const {},
  Set<RoutineTime> times = const {RoutineTime.morning, RoutineTime.night},
  ProductCategory category = ProductCategory.treatment,
  Set<SkinType> skinTypes = const {},
  bool strong = false,
  bool noPregnancy = false,
  bool fragranceFree = false,
}) => Product(
  id: id,
  name: id,
  category: category,
  pricePkr: 100,
  times: times,
  ingredients: ingredients,
  skinTypes: skinTypes,
  isStrongActive: strong,
  avoidInPregnancy: noPregnancy,
  fragranceFree: fragranceFree,
);

Routine routine({
  List<Product> morning = const [],
  List<Product> night = const [],
}) => Routine(
  morning: [
    for (final (i, p) in morning.indexed)
      RoutineStep(number: i + 1, product: p),
  ],
  night: [
    for (final (i, p) in night.indexed) RoutineStep(number: i + 1, product: p),
  ],
);

void main() {
  const find = FindIngredientClashes();

  group('ingredient clashes', () {
    final niacinamide = product(
      'niacinamide',
      ingredients: {Ingredient.niacinamide, Ingredient.zinc},
    );
    final vitaminC = product(
      'vitc',
      ingredients: {Ingredient.vitaminC},
      times: {RoutineTime.morning},
      strong: true,
    );
    final retinol = product(
      'retinol',
      ingredients: {Ingredient.retinol},
      times: {RoutineTime.night},
      strong: true,
    );
    final acid = product(
      'acid',
      ingredients: {Ingredient.salicylicAcid},
      times: {RoutineTime.night},
      strong: true,
    );
    final benzoyl = product(
      'bp',
      ingredients: {Ingredient.benzoylPeroxide},
      times: {RoutineTime.night},
    );

    test('niacinamide clashes with the vitamin C in the morning routine', () {
      final clashes = find(niacinamide, routine(morning: [vitaminC]));
      expect(clashes, hasLength(1));
      expect(clashes.single.rule, ClashRule.niacinamideAndVitaminC);
      expect(clashes.single.withProduct, vitaminC);
      expect(clashes.single.time, RoutineTime.morning);
    });

    test(
      'it can still be used at night, so the advice is to move it there',
      () {
        final clash = find(niacinamide, routine(morning: [vitaminC])).single;
        expect(clash.canMoveToOtherTime, isTrue);
      },
    );

    test(
      'vitamin C at night clashes at night, and it can move to the morning',
      () {
        final clash = find(niacinamide, routine(night: [vitaminC])).single;
        expect(clash.time, RoutineTime.night);
        expect(clash.canMoveToOtherTime, isTrue);
      },
    );

    test('no clash when the two are never used at the same time of day', () {
      final morningOnly = product(
        'm',
        ingredients: {Ingredient.niacinamide},
        times: {RoutineTime.morning},
      );
      expect(find(morningOnly, routine(night: [vitaminC])), isEmpty);
    });

    test('a morning-only product cannot be moved to night', () {
      final morningNiacinamide = product(
        'm',
        ingredients: {Ingredient.niacinamide},
        times: {RoutineTime.morning},
      );
      final clash = find(
        morningNiacinamide,
        routine(morning: [vitaminC]),
      ).single;
      expect(clash.canMoveToOtherTime, isFalse);
    });

    test('retinol clashes with an exfoliating acid used the same night', () {
      final clashes = find(retinol, routine(night: [acid]));
      expect(clashes.single.rule, ClashRule.retinolAndExfoliants);
      expect(clashes.single.time, RoutineTime.night);
    });

    test('the rule works whichever of the two is being scanned', () {
      expect(
        find(acid, routine(night: [retinol])).single.rule,
        ClashRule.retinolAndExfoliants,
      );
    });

    test('retinol and benzoyl peroxide clash', () {
      expect(
        find(retinol, routine(night: [benzoyl])).single.rule,
        ClashRule.benzoylPeroxideAndRetinol,
      );
    });

    test('retinol and vitamin C are not used together, so no clash', () {
      expect(find(retinol, routine(morning: [vitaminC])), isEmpty);
    });

    test('the same product in the routine is not a clash with itself', () {
      expect(find(vitaminC, routine(morning: [vitaminC])), isEmpty);
    });

    test('an empty routine or a product with no known ingredients is fine', () {
      expect(find(niacinamide, routine()), isEmpty);
      expect(find(product('plain'), routine(morning: [vitaminC])), isEmpty);
    });

    test('each clashing product is reported once', () {
      final twice = find(
        niacinamide,
        routine(morning: [vitaminC], night: [vitaminC]),
      );
      expect(twice.where((c) => c.withProduct == vitaminC).length, 1);
    });
  });

  group('product fit', () {
    const assess = AssessProduct();

    test('suits the skin type: a good match', () {
      final serum = product('s', skinTypes: {SkinType.oily});
      expect(
        assess(serum, const SkinProfile(skinType: SkinType.oily)),
        ProductFit.good,
      );
    });

    test('gentle for any skin type: a good match', () {
      expect(
        assess(product('s'), const SkinProfile(skinType: SkinType.dry)),
        ProductFit.good,
      );
    });

    test('no answers yet: a good match, nothing says otherwise', () {
      expect(
        assess(product('s', skinTypes: {SkinType.oily}), const SkinProfile()),
        ProductFit.good,
      );
    });

    test('made for another skin type: use with care', () {
      final serum = product('s', skinTypes: {SkinType.oily});
      expect(
        assess(serum, const SkinProfile(skinType: SkinType.dry)),
        ProductFit.careful,
      );
    });

    test('"not sure" is never penalised for skin type', () {
      final serum = product('s', skinTypes: {SkinType.oily});
      expect(
        assess(serum, const SkinProfile(skinType: SkinType.notSure)),
        ProductFit.good,
      );
    });

    test('a strong active with sensitive skin: use with care', () {
      final strongSerum = product('s', strong: true);
      expect(
        assess(strongSerum, const SkinProfile(sensitivity: Sensitivity.high)),
        ProductFit.careful,
      );
    });

    test('pregnancy and a product usually avoided then: not for you', () {
      final retinoid = product('r', strong: true, noPregnancy: true);
      expect(
        assess(
          retinoid,
          const SkinProfile(safetyFlags: {SafetyFlag.pregnantOrBreastfeeding}),
        ),
        ProductFit.avoid,
      );
    });

    test('an ingredient allergy and a product with fragrance: not for you', () {
      expect(
        assess(
          product('scented'),
          const SkinProfile(safetyFlags: {SafetyFlag.ingredientAllergy}),
        ),
        ProductFit.avoid,
      );
      expect(
        assess(
          product('plain', fragranceFree: true),
          const SkinProfile(safetyFlags: {SafetyFlag.ingredientAllergy}),
        ),
        ProductFit.good,
      );
    });

    test('prescription treatment and a strong active: not for you', () {
      expect(
        assess(
          product('s', strong: true),
          const SkinProfile(safetyFlags: {SafetyFlag.prescriptionTreatment}),
        ),
        ProductFit.avoid,
      );
    });

    test('the most serious reason wins', () {
      final both = product(
        'r',
        strong: true,
        noPregnancy: true,
        skinTypes: {SkinType.oily},
      );
      expect(
        assess(
          both,
          const SkinProfile(
            skinType: SkinType.dry,
            safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
          ),
        ),
        ProductFit.avoid,
      );
    });
  });
}
