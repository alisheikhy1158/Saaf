// Covers: the user's own products in their routine — they come first in their
// step, Saaf AI can only replace them by saying so, and the safety answers
// still apply (on the phone)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/usecases/build_routine.dart';

const _catalogue = [
  Product(
    id: 'c-1',
    name: 'Catalogue Cleanser',
    category: ProductCategory.cleanser,
    pricePkr: 500,
    times: {RoutineTime.morning, RoutineTime.night},
  ),
  Product(
    id: 'm-1',
    name: 'Catalogue Cream',
    category: ProductCategory.moisturiser,
    pricePkr: 800,
    times: {RoutineTime.morning, RoutineTime.night},
  ),
  Product(
    id: 's-1',
    name: 'Catalogue SPF',
    category: ProductCategory.sunscreen,
    pricePkr: 900,
    times: {RoutineTime.morning},
  ),
];

List<String> _names(Routine r) => [
  for (final s in [...r.morning, ...r.night]) s.product.name,
];

Routine _build(
  List<OwnedProduct> owned, {
  AiRoutinePlan? plan,
  SkinProfile profile = const SkinProfile(),
}) {
  final mine = OwnedProduct.productsFor(owned, plan);
  return BuildRoutine(
    [..._catalogue, ...?plan?.products, ...mine],
    preferred: plan?.productIds ?? const {},
    owned: {for (final p in mine) p.id},
  )(profile);
}

void main() {
  test('the user’s own products take their step', () {
    final routine = _build(const [
      OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
      OwnedProduct(name: 'Himalaya Neem', step: ProductCategory.cleanser),
      OwnedProduct(name: 'Lip balm'), // "other": not in the routine
    ]);
    expect(_names(routine), containsAll(['Nivea Soft', 'Himalaya Neem']));
    expect(_names(routine), isNot(contains('Catalogue Cleanser')));
    expect(_names(routine), isNot(contains('Catalogue Cream')));
    expect(_names(routine), contains('Catalogue SPF')); // a step they lack
    expect(_names(routine), isNot(contains('Lip balm')));
  });

  test('the price they paid counts in the routine; none is 0', () {
    final mine = OwnedProduct.productsFor(const [
      OwnedProduct(
        name: 'Nivea Soft',
        step: ProductCategory.moisturiser,
        pricePkr: 900,
      ),
    ], null).single;
    expect(mine.pricePkr, 900);
  });

  test('a priced product of theirs is never swapped to fit the budget', () {
    final routine = _build(const [
      OwnedProduct(
        name: 'Dear Cleanser',
        step: ProductCategory.cleanser,
        pricePkr: 5000,
      ),
    ], profile: const SkinProfile(budget: BudgetBand.essential));
    expect(_names(routine), contains('Dear Cleanser'));
    expect(_names(routine), isNot(contains('Catalogue Cleanser')));
    expect(routine.monthlyCostPkr, greaterThan(5000));
    expect(routine.fitsBudget, isFalse);
  });

  test('their product is marked as theirs and has no price', () {
    final mine = OwnedProduct.productsFor(const [
      OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
    ], null).single;
    expect(OwnedProduct.isOwned(mine), isTrue);
    expect(mine.pricePkr, 0);
    expect(OwnedProduct.isOwned(_catalogue.first), isFalse);
  });

  test('Saaf AI saying replace or stop takes it out; keep leaves it', () {
    const plan = AiRoutinePlan(
      summary: '',
      picks: [],
      current: [
        CurrentProductReview(
          name: 'Nivea Soft',
          verdict: ProductVerdict.replace,
          why: 'Heavy.',
        ),
        CurrentProductReview(
          name: 'himalaya neem', // matched without caring about case
          verdict: ProductVerdict.keep,
          why: 'Fine.',
        ),
      ],
    );
    final routine = _build(const [
      OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
      OwnedProduct(name: 'Himalaya Neem', step: ProductCategory.cleanser),
    ], plan: plan);
    expect(_names(routine), isNot(contains('Nivea Soft')));
    expect(_names(routine), contains('Himalaya Neem'));
  });

  test('a strong product they use stays, even without a matching concern', () {
    const plan = AiRoutinePlan(
      summary: '',
      picks: [],
      current: [
        CurrentProductReview(
          name: 'My Retinol',
          verdict: ProductVerdict.keep,
          why: 'Ok.',
          actives: {Ingredient.retinol},
        ),
      ],
    );
    final routine = _build(const [
      OwnedProduct(name: 'My Retinol', step: ProductCategory.treatment),
    ], plan: plan);
    expect(_names(routine), contains('My Retinol'));
  });

  test('but never when the safety answers rule it out', () {
    const plan = AiRoutinePlan(
      summary: '',
      picks: [],
      current: [
        CurrentProductReview(
          name: 'My Retinol',
          verdict: ProductVerdict.keep,
          why: 'Ok.',
          actives: {Ingredient.retinol},
        ),
      ],
    );
    final routine = _build(
      const [OwnedProduct(name: 'My Retinol', step: ProductCategory.treatment)],
      plan: plan,
      profile: const SkinProfile(
        safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
      ),
    );
    expect(_names(routine), isNot(contains('My Retinol')));
  });

  test('reads and writes the saved list, including the old names-only one', () {
    const list = [
      OwnedProduct(
        name: 'Nivea Soft',
        step: ProductCategory.moisturiser,
        pricePkr: 900,
      ),
      OwnedProduct(name: 'Lip balm'),
    ];
    expect(OwnedProduct.decodeList(OwnedProduct.encodeList(list)), list);
    expect(OwnedProduct.decodeList('["Nivea Soft"]'), const [
      OwnedProduct(name: 'Nivea Soft'),
    ]);
    expect(OwnedProduct.decodeList('not json'), isEmpty);
  });
}
