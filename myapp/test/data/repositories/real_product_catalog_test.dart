// Covers: the real product catalogue (named products sold in Pakistan) — it
// must be complete enough for every skin type and budget, and safe by default
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/real_product_catalog.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/build_routine.dart';

void main() {
  const products = RealProductCatalog.products;

  group('the data', () {
    test('every product has a unique id and a real brand name', () {
      expect({for (final p in products) p.id}.length, products.length);
      for (final p in products) {
        expect(p.name.trim().split(' ').length, greaterThan(1), reason: p.id);
        expect(p.name, isNot(contains('Placeholder')));
      }
    });

    test('all four kinds of product are there, with a choice in each', () {
      for (final category in ProductCategory.values) {
        expect(
          products.where((p) => p.category == category).length,
          greaterThanOrEqualTo(3),
          reason: '$category',
        );
      }
    });

    test('prices are in a believable range for Pakistan', () {
      for (final p in products) {
        expect(p.pricePkr, inInclusiveRange(300, 15000), reason: p.id);
      }
    });

    test('sunscreen is morning only', () {
      for (final p in products.where(
        (p) => p.category == ProductCategory.sunscreen,
      )) {
        expect(p.times, {RoutineTime.morning}, reason: p.id);
      }
    });

    test(
      'retinol and salicylic acid are strong actives, avoided in pregnancy',
      () {
        for (final p in products.where(
          (p) =>
              p.ingredients.contains(Ingredient.retinol) ||
              p.ingredients.contains(Ingredient.salicylicAcid),
        )) {
          expect(p.isStrongActive, isTrue, reason: p.id);
          expect(p.avoidInPregnancy, isTrue, reason: p.id);
          expect(p.times, {RoutineTime.night}, reason: p.id);
        }
      },
    );

    test('vitamin C is only suggested in the morning, never at night', () {
      for (final p in products.where(
        (p) => p.ingredients.contains(Ingredient.vitaminC),
      )) {
        expect(p.times, {RoutineTime.morning}, reason: p.id);
      }
    });

    test('cleansers do not carry clash-relevant actives (rinse-off)', () {
      for (final p in products.where(
        (p) => p.category == ProductCategory.cleanser,
      )) {
        expect(
          p.ingredients.intersection({
            Ingredient.niacinamide,
            Ingredient.vitaminC,
            Ingredient.retinol,
            Ingredient.aha,
            Ingredient.salicylicAcid,
            Ingredient.benzoylPeroxide,
          }),
          isEmpty,
          reason: p.id,
        );
      }
    });

    test('the catalogue date is set (prices are a guide as of then)', () {
      expect(RealProductCatalog.pricesCheckedOn.year, 2026);
    });
  });

  group('building routines from it', () {
    const build = BuildRoutine(products);

    SkinProfile profile(
      SkinType type,
      BudgetBand budget, {
      Set<SkinConcern> concerns = const {SkinConcern.acne},
      Set<SafetyFlag>? flags,
      Sensitivity? sensitivity,
    }) => SkinProfile(
      skinType: type,
      concerns: concerns,
      budget: budget,
      safetyFlags: flags,
      sensitivity: sensitivity,
    );

    test('oily skin and acne get a cleanser, a moisturiser and sunscreen', () {
      final routine = build(profile(SkinType.oily, BudgetBand.premium));
      final morning = routine.morning.map((s) => s.product.category).toSet();
      expect(
        morning,
        containsAll({
          ProductCategory.cleanser,
          ProductCategory.moisturiser,
          ProductCategory.sunscreen,
        }),
      );
    });

    test('dry skin gets dry-skin products', () {
      final routine = build(
        profile(
          SkinType.dry,
          BudgetBand.premium,
          concerns: {SkinConcern.dryness},
        ),
      );
      final cleanser = routine.morning.firstWhere(
        (s) => s.product.category == ProductCategory.cleanser,
      );
      expect(cleanser.product.skinTypes, contains(SkinType.dry));
    });

    for (final skin in SkinType.values) {
      for (final budget in BudgetBand.values) {
        test('$skin on a $budget budget still gets a routine', () {
          final routine = build(profile(skin, budget));
          expect(routine.morning, isNotEmpty);
          expect(routine.night, isNotEmpty);
        });
      }
    }

    test('the cheapest budget picks affordable local products', () {
      final routine = build(profile(SkinType.oily, BudgetBand.essential));
      final all = {...routine.morning, ...routine.night};
      final total = {
        for (final s in all) s.product,
      }.fold(0, (sum, p) => sum + p.pricePkr);
      // Essentials only: the cheapest real products add up to about this.
      expect(total, lessThan(4500));
    });

    test('pregnancy leaves out retinol and salicylic acid', () {
      final routine = build(
        profile(
          SkinType.oily,
          BudgetBand.premium,
          concerns: {SkinConcern.acne, SkinConcern.darkSpots},
          flags: {SafetyFlag.pregnantOrBreastfeeding},
        ),
      );
      final used = {...routine.morning, ...routine.night};
      for (final step in used) {
        expect(step.product.avoidInPregnancy, isFalse, reason: step.product.id);
      }
    });

    test('high sensitivity leaves out the strong actives', () {
      final routine = build(
        profile(
          SkinType.combination,
          BudgetBand.premium,
          concerns: {SkinConcern.acne, SkinConcern.darkSpots},
          sensitivity: Sensitivity.high,
        ),
      );
      for (final step in {...routine.morning, ...routine.night}) {
        expect(step.product.isStrongActive, isFalse, reason: step.product.id);
      }
    });
  });
}
