// Covers: 08 Routine — BuildRoutine picks one product per step for the user's skin,
// concerns, safety flags and monthly budget (store-compliance: health flags stay
// on the device and only filter the routine; never a diagnosis)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/build_routine.dart';

Product p(
  String id,
  ProductCategory category,
  int price, {
  Set<RoutineTime>? times,
  Set<SkinType> skinTypes = const {},
  Set<SkinConcern> targets = const {},
  bool strong = false,
  bool noPregnancy = false,
  bool fragranceFree = false,
}) => Product(
  id: id,
  name: id,
  category: category,
  pricePkr: price,
  times:
      times ??
      (category == ProductCategory.sunscreen
          ? {RoutineTime.morning}
          : {RoutineTime.morning, RoutineTime.night}),
  skinTypes: skinTypes,
  targets: targets,
  isStrongActive: strong,
  avoidInPregnancy: noPregnancy,
  fragranceFree: fragranceFree,
);

Iterable<String> ids(List<RoutineStep> steps) => steps.map((s) => s.product.id);

void main() {
  final seed = SeedProductCatalog.products;
  BuildRoutine seeded() => BuildRoutine(seed);

  group('shape', () {
    test(
      'morning is cleanser, treatment, moisturiser, sunscreen, numbered 1–4',
      () {
        final routine = seeded()(const SkinProfile());
        expect(routine.morning.map((s) => s.product.category), [
          ProductCategory.cleanser,
          ProductCategory.treatment,
          ProductCategory.moisturiser,
          ProductCategory.sunscreen,
        ]);
        expect(routine.morning.map((s) => s.number), [1, 2, 3, 4]);
      },
    );

    test('night has no sunscreen and is numbered from 1', () {
      final routine = seeded()(const SkinProfile());
      expect(
        routine.night.map((s) => s.product.category),
        isNot(contains(ProductCategory.sunscreen)),
      );
      expect(routine.night.map((s) => s.number), [1, 2, 3]);
    });

    test('every step can be used at the time it is shown', () {
      final routine = seeded()(
        const SkinProfile(skinType: SkinType.combination),
      );
      expect(
        routine.morning.every(
          (s) => s.product.times.contains(RoutineTime.morning),
        ),
        isTrue,
      );
      expect(
        routine.night.every((s) => s.product.times.contains(RoutineTime.night)),
        isTrue,
      );
    });

    test('cleanser and moisturiser are shared between morning and night', () {
      final routine = seeded()(const SkinProfile(skinType: SkinType.dry));
      expect(routine.morning.first.product, routine.night.first.product);
      expect(routine.morning[2].product.id, routine.night[2].product.id);
    });

    test('totals, step count and time', () {
      final routine = BuildRoutine([
        p('c', ProductCategory.cleanser, 100),
        p('t', ProductCategory.treatment, 300),
        p('m', ProductCategory.moisturiser, 200),
        p('s', ProductCategory.sunscreen, 400),
      ])(const SkinProfile());
      expect(routine.totalFor(RoutineTime.morning), 1000);
      expect(routine.totalFor(RoutineTime.night), 600);
      expect(routine.monthlyCostPkr, 1000); // each product counted once
      expect(routine.minutesFor(RoutineTime.morning), 5);
      expect(routine.minutesFor(RoutineTime.night), 4);
    });

    test('an empty catalog gives an empty routine, not a crash', () {
      final routine = const BuildRoutine([])(const SkinProfile());
      expect(routine.morning, isEmpty);
      expect(routine.night, isEmpty);
      expect(routine.monthlyCostPkr, 0);
    });

    test('a missing category is skipped and the rest renumbered', () {
      final routine = BuildRoutine([
        p('c', ProductCategory.cleanser, 100),
        p('m', ProductCategory.moisturiser, 200),
      ])(const SkinProfile());
      expect(ids(routine.morning), ['c', 'm']);
      expect(routine.morning.map((s) => s.number), [1, 2]);
    });

    test('the same answers always give the same routine', () {
      const profile = SkinProfile(
        skinType: SkinType.combination,
        concerns: {SkinConcern.acne, SkinConcern.darkSpots},
        budget: BudgetBand.balanced,
      );
      expect(ids(seeded()(profile).morning), ids(seeded()(profile).morning));
      expect(ids(seeded()(profile).night), ids(seeded()(profile).night));
    });
  });

  group('matching the skin', () {
    test('oily skin with dark spots and breakouts gets the Figma routine', () {
      final routine = seeded()(
        const SkinProfile(
          skinType: SkinType.oily,
          concerns: {SkinConcern.darkSpots, SkinConcern.acne},
          budget: BudgetBand.balanced,
        ),
      );
      expect(routine.morning.map((s) => (s.product.name, s.product.pricePkr)), [
        ('Neem Face Wash', 650),
        ('Niacinamide Serum', 1450),
        ('Oil-free Gel Moisturiser', 1100),
        ('Matte SPF 50 Sunscreen', 1850),
      ]);
      expect(routine.totalFor(RoutineTime.morning), 5050);
      expect(routine.fitsBudget, isTrue);
    });

    test('dry skin gets hydrating products', () {
      final routine = seeded()(
        const SkinProfile(
          skinType: SkinType.dry,
          concerns: {SkinConcern.dryness},
        ),
      );
      final names = routine.morning.map((s) => s.product.name).toList();
      expect(names, contains('Gentle Cream Cleanser'));
      expect(names, contains('Hyaluronic Acid Serum'));
      expect(names, contains('Rich Barrier Cream'));
      expect(names, contains('Hydrating SPF 50 Sunscreen'));
    });

    test('a concern the user picked decides the treatment', () {
      final routine = BuildRoutine([
        p('c', ProductCategory.cleanser, 100),
        p(
          'spots',
          ProductCategory.treatment,
          500,
          targets: {SkinConcern.darkSpots},
        ),
        p('acne', ProductCategory.treatment, 500, targets: {SkinConcern.acne}),
        p('m', ProductCategory.moisturiser, 100),
        p('s', ProductCategory.sunscreen, 100),
      ])(const SkinProfile(concerns: {SkinConcern.acne}));
      expect(routine.morning[1].product.id, 'acne');
    });

    test('equal matches pick the cheaper product', () {
      final routine = BuildRoutine([
        p('dear', ProductCategory.cleanser, 900),
        p('cheap', ProductCategory.cleanser, 400),
      ])(const SkinProfile());
      expect(routine.morning.single.product.id, 'cheap');
    });

    test('"not sure" and no answer start with gentle all-skin products', () {
      for (final type in [null, SkinType.notSure]) {
        final routine = BuildRoutine([
          p('oily', ProductCategory.cleanser, 100, skinTypes: {SkinType.oily}),
          p('all', ProductCategory.cleanser, 300),
        ])(SkinProfile(skinType: type));
        expect(routine.morning.single.product.id, 'all', reason: '$type');
      }
    });

    test('the concerns are kept for the screen subtitle', () {
      final routine = seeded()(
        const SkinProfile(concerns: {SkinConcern.acne, SkinConcern.oiliness}),
      );
      expect(routine.concerns, [SkinConcern.acne, SkinConcern.oiliness]);
    });
  });

  group('safety', () {
    final strongCatalog = [
      p('c', ProductCategory.cleanser, 100, fragranceFree: true),
      p(
        'strong',
        ProductCategory.treatment,
        100,
        strong: true,
        noPregnancy: true,
        targets: {SkinConcern.acne},
      ),
      p('mild', ProductCategory.treatment, 900, fragranceFree: true),
      p('m', ProductCategory.moisturiser, 100, fragranceFree: true),
      p('s', ProductCategory.sunscreen, 100, fragranceFree: true),
    ];

    test('without flags the strong active is used', () {
      final r = BuildRoutine(strongCatalog)(
        const SkinProfile(concerns: {SkinConcern.acne}),
      );
      expect(r.morning[1].product.id, 'strong');
    });

    test('pregnant or breastfeeding: nothing marked unsafe in pregnancy', () {
      final r = BuildRoutine(strongCatalog)(
        const SkinProfile(
          concerns: {SkinConcern.acne},
          safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
        ),
      );
      expect(r.morning[1].product.id, 'mild');
    });

    test('prescription treatment: no strong actives', () {
      final r = BuildRoutine(strongCatalog)(
        const SkinProfile(
          concerns: {SkinConcern.acne},
          safetyFlags: {SafetyFlag.prescriptionTreatment},
        ),
      );
      expect(r.morning[1].product.id, 'mild');
    });

    test('high sensitivity: no strong actives', () {
      final r = BuildRoutine(strongCatalog)(
        const SkinProfile(
          concerns: {SkinConcern.acne},
          sensitivity: Sensitivity.high,
        ),
      );
      expect(r.morning[1].product.id, 'mild');
    });

    test('an ingredient allergy keeps only fragrance-free products', () {
      final r = BuildRoutine([
        p('scented', ProductCategory.cleanser, 100),
        p('plain', ProductCategory.cleanser, 500, fragranceFree: true),
      ])(const SkinProfile(safetyFlags: {SafetyFlag.ingredientAllergy}));
      expect(r.morning.single.product.id, 'plain');
    });

    test('if nothing is safe the step is left out, never forced', () {
      final r = BuildRoutine([
        p('strong', ProductCategory.treatment, 100, strong: true),
      ])(const SkinProfile(sensitivity: Sensitivity.high));
      expect(r.morning, isEmpty);
    });

    test('the real catalogue always gives a full routine under every flag', () {
      for (final flags in [
        <SafetyFlag>{},
        {SafetyFlag.pregnantOrBreastfeeding},
        {SafetyFlag.prescriptionTreatment},
        {SafetyFlag.ingredientAllergy},
        SafetyFlag.values.toSet(),
      ]) {
        for (final type in SkinType.values) {
          final r = seeded()(
            SkinProfile(
              skinType: type,
              concerns: const {SkinConcern.darkSpots, SkinConcern.acne},
              sensitivity: Sensitivity.high,
              safetyFlags: flags,
            ),
          );
          final cats = r.morning.map((s) => s.product.category).toSet();
          expect(
            cats,
            containsAll([
              ProductCategory.cleanser,
              ProductCategory.moisturiser,
              ProductCategory.sunscreen,
            ]),
            reason: '$type $flags',
          );
          for (final s in [...r.morning, ...r.night]) {
            expect(s.product.isStrongActive, isFalse, reason: '$type $flags');
            if (flags.contains(SafetyFlag.pregnantOrBreastfeeding)) {
              expect(s.product.avoidInPregnancy, isFalse);
            }
            if (flags.contains(SafetyFlag.ingredientAllergy)) {
              expect(s.product.fragranceFree, isTrue);
            }
          }
        }
      }
    });
  });

  group('budget', () {
    test('the monthly cost stays within each band for the real catalogue', () {
      for (final band in BudgetBand.values) {
        final r = seeded()(
          SkinProfile(
            skinType: SkinType.oily,
            concerns: const {SkinConcern.darkSpots, SkinConcern.acne},
            budget: band,
          ),
        );
        final limit = band.maxMonthlyPkr;
        if (limit != null) {
          expect(r.monthlyCostPkr, lessThanOrEqualTo(limit), reason: '$band');
          expect(r.fitsBudget, isTrue, reason: '$band');
        }
        expect(r.morning.length, greaterThanOrEqualTo(3), reason: '$band');
      }
    });

    test('a tight budget drops the treatment before anything else', () {
      final r = BuildRoutine([
        p('c', ProductCategory.cleanser, 500),
        p('t', ProductCategory.treatment, 1500),
        p('m', ProductCategory.moisturiser, 500),
        p('s', ProductCategory.sunscreen, 800),
      ])(const SkinProfile(budget: BudgetBand.essential));
      expect(ids(r.morning), ['c', 'm', 's']);
      expect(r.fitsBudget, isTrue);
    });

    test('a cheaper alternative is preferred to dropping a step', () {
      final r =
          BuildRoutine([
            p('c', ProductCategory.cleanser, 500),
            p(
              'fancy',
              ProductCategory.treatment,
              2500,
              targets: {SkinConcern.darkSpots},
            ),
            p('basic', ProductCategory.treatment, 700),
            p('m', ProductCategory.moisturiser, 500),
            p('s', ProductCategory.sunscreen, 800),
          ])(
            const SkinProfile(
              concerns: {SkinConcern.darkSpots},
              budget: BudgetBand.essential,
            ),
          );
      expect(ids(r.morning), contains('basic'));
      expect(r.monthlyCostPkr, lessThanOrEqualTo(3000));
    });

    test('premium has no limit, so the best match wins whatever it costs', () {
      final r =
          BuildRoutine([
            p('c', ProductCategory.cleanser, 100),
            p(
              'luxe',
              ProductCategory.treatment,
              90000,
              targets: {SkinConcern.acne},
            ),
            p('basic', ProductCategory.treatment, 100),
            p('m', ProductCategory.moisturiser, 100),
            p('s', ProductCategory.sunscreen, 100),
          ])(
            const SkinProfile(
              concerns: {SkinConcern.acne},
              budget: BudgetBand.premium,
            ),
          );
      expect(r.morning[1].product.id, 'luxe');
      expect(r.fitsBudget, isTrue);
    });

    test('when even the cheapest routine is too dear, it says so', () {
      final r = BuildRoutine([
        p('c', ProductCategory.cleanser, 2000),
        p('m', ProductCategory.moisturiser, 2000),
        p('s', ProductCategory.sunscreen, 2000),
      ])(const SkinProfile(budget: BudgetBand.essential));
      expect(r.morning.length, 3);
      expect(r.fitsBudget, isFalse);
    });

    test('no budget answer means no limit', () {
      final r = seeded()(const SkinProfile());
      expect(r.budget, isNull);
      expect(r.fitsBudget, isTrue);
    });
  });
}
