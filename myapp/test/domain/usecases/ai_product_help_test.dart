// Covers: Saaf AI planning the routine from the web and looking products up
// (store-compliance §5) — only after consent, the safety answers never leave
// the phone, and the phone itself checks every AI product against them
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/active_rules.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/build_routine.dart';
import 'package:saaf/domain/usecases/look_up_product.dart';
import 'package:saaf/domain/usecases/plan_routine.dart';

/// A product as Saaf AI would bring it back from the web.
Product _web(
  String id,
  ProductCategory category,
  Set<Ingredient> actives, {
  bool fragranceFree = true,
}) => ActiveRules.product(
  id: id,
  name: id,
  category: category,
  pricePkr: 1000,
  times: category == ProductCategory.sunscreen
      ? const {RoutineTime.morning}
      : const {RoutineTime.morning, RoutineTime.night},
  actives: actives,
  fragranceFree: fragranceFree,
);

class _Service implements AiProductService {
  int calls = 0;
  AiContext? context;
  Map<SkinMetricKind, double>? scan;
  List<OwnedProduct>? current;
  ProductQuery? query;

  @override
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<OwnedProduct> currentProducts,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    calls++;
    this.context = context;
    this.scan = scan;
    current = currentProducts;
    return Ok(
      AiRoutinePlan(
        summary: 'Gentle picks.',
        picks: [
          AiPick(
            product: _web('ai-c', ProductCategory.cleanser, const {}),
            brand: 'CeraVe',
            why: 'Gentle.',
            reviews: 'Liked on Reddit.',
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  }) async {
    calls++;
    this.query = query;
    this.context = context;
    return const Ok(
      ProductInsight(
        title: 'CeraVe Cleanser',
        text: 'Gentle.',
        webChecked: true,
      ),
    );
  }
}

const _pregnantWithAcne = SkinProfile(
  skinType: SkinType.oily,
  concerns: {SkinConcern.acne, SkinConcern.darkSpots},
  budget: BudgetBand.balanced,
  safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
);

final _analysis = SkinAnalysis(
  scanId: 's1',
  takenAt: DateTime(2026, 10, 17),
  metrics: const [
    SkinMetric(kind: SkinMetricKind.darkSpots, amount: 0.6),
    SkinMetric(kind: SkinMetricKind.hydration, amount: 0.4),
  ],
);

Future<AiConsent> _consent({required bool given}) async {
  final consent = AiConsent(InMemorySettingsRepository());
  if (given) await consent.give();
  return consent;
}

void main() {
  late _Service service;
  setUp(() => service = _Service());

  group('PlanRoutine', () {
    Future<Result<AiRoutinePlan>> plan({
      bool consent = true,
      SkinProfile profile = _pregnantWithAcne,
      List<OwnedProduct> current = const [
        OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
      ],
      SkinAnalysis? analysis,
    }) async =>
        PlanRoutine(
          service: service,
          consent: await _consent(given: consent),
        )(
          profile: profile,
          currentProducts: current,
          analysis: analysis,
          languageCode: 'ur',
        );

    test('nothing is sent without consent', () async {
      expect(
        (await plan(consent: false)).failureOrNull,
        const ConsentMissing(),
      );
      expect(service.calls, 0);
    });

    test('sends the skin facts, language and current products only', () async {
      await plan();
      final context = service.context!;
      expect(context.languageCode, 'ur');
      expect(context.skinType, SkinType.oily);
      expect(context.concerns, {SkinConcern.acne, SkinConcern.darkSpots});
      expect(context.budget, BudgetBand.balanced);
      expect(service.current, const [
        OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
      ]);
      // AiContext has no field for the safety answers at all.
    });

    test('the latest scan scores go along when there is a scan', () async {
      await plan(analysis: _analysis);
      expect(service.scan, {
        SkinMetricKind.darkSpots: 0.6,
        SkinMetricKind.hydration: 0.4,
      });
      await plan();
      expect(service.scan, isEmpty);
    });

    test('the plan comes back', () async {
      final result = (await plan()).valueOrNull!;
      expect(result.summary, 'Gentle picks.');
      expect(result.productIds, {'ai-c'});
      expect(result.pickFor('ai-c')?.brand, 'CeraVe');
    });
  });

  group('the phone checks AI products against the safety answers', () {
    test('ingredients decide strength, pregnancy advice and what it helps', () {
      expect(ActiveRules.isStrong({Ingredient.retinol}), isTrue);
      expect(ActiveRules.isStrong({Ingredient.niacinamide}), isFalse);
      expect(ActiveRules.avoidInPregnancy({Ingredient.salicylicAcid}), isTrue);
      expect(ActiveRules.avoidInPregnancy({Ingredient.azelaicAcid}), isFalse);
      expect(
        ActiveRules.helpsWith({Ingredient.salicylicAcid}),
        contains(SkinConcern.acne),
      );
    });

    test('a retinol pick never reaches a pregnant user’s routine', () {
      final retinol = _web('ai-retinol', ProductCategory.treatment, {
        Ingredient.retinol,
      });
      final cleanser = _web('ai-c', ProductCategory.cleanser, const {});
      final routine = BuildRoutine(
        [retinol, cleanser],
        preferred: {'ai-retinol', 'ai-c'},
      )(_pregnantWithAcne);
      final ids = [
        for (final s in [...routine.morning, ...routine.night]) s.product.id,
      ];
      expect(ids, isNot(contains('ai-retinol')));
      expect(ids, contains('ai-c'));
    });

    test('a strong AI pick reaches a user with a matching concern', () {
      final salicylic = _web('ai-bha', ProductCategory.treatment, {
        Ingredient.salicylicAcid,
      });
      final routine = BuildRoutine([salicylic], preferred: {'ai-bha'})(
        const SkinProfile(concerns: {SkinConcern.acne}),
      );
      expect(routine.morning.single.product.id, 'ai-bha');
    });

    test('a product the user keeps is flagged when it clashes with them', () {
      const keepRetinol = CurrentProductReview(
        name: 'Night serum',
        verdict: ProductVerdict.keep,
        why: 'Good for marks.',
        actives: {Ingredient.retinol},
      );
      expect(
        keepRetinol.cautionFor(_pregnantWithAcne),
        ProductCaution.pregnancy,
      );
      expect(
        keepRetinol.cautionFor(
          const SkinProfile(safetyFlags: {SafetyFlag.prescriptionTreatment}),
        ),
        ProductCaution.prescription,
      );
      expect(
        keepRetinol.cautionFor(
          const SkinProfile(sensitivity: Sensitivity.high),
        ),
        ProductCaution.sensitive,
      );
      expect(keepRetinol.cautionFor(const SkinProfile()), isNull);
    });

    test('no caution on a product Saaf AI already says to stop', () {
      const stop = CurrentProductReview(
        name: 'Whitening cream',
        verdict: ProductVerdict.stop,
        why: 'Harmful.',
        actives: {Ingredient.retinol},
      );
      expect(stop.cautionFor(_pregnantWithAcne), isNull);
    });
  });

  group('LookUpProduct', () {
    Future<Result<ProductInsight>> lookUp(
      ProductQuery query, {
      bool consent = true,
    }) async => LookUpProduct(
      service: service,
      consent: await _consent(given: consent),
    )(query: query, profile: _pregnantWithAcne, languageCode: 'en');

    test('nothing is sent without consent', () async {
      expect(
        (await lookUp(
          const ProductBarcodeQuery('3337875743563'),
          consent: false,
        )).failureOrNull,
        const ConsentMissing(),
      );
      expect(service.calls, 0);
    });

    test('sends the query with the skin facts', () async {
      final result = await lookUp(const ProductQrQuery('https://x.example'));
      expect(result.valueOrNull?.title, 'CeraVe Cleanser');
      expect(service.query, const ProductQrQuery('https://x.example'));
      expect(service.context?.skinType, SkinType.oily);
      expect(service.context?.routineProducts, isEmpty);
    });

    test('refuses an empty photo or a bad barcode without sending', () async {
      expect(
        (await lookUp(ProductPhotoQuery(Uint8List(0)))).failureOrNull,
        isA<ValidationFailure>(),
      );
      expect(
        (await lookUp(const ProductBarcodeQuery('12ab'))).failureOrNull,
        isA<ValidationFailure>(),
      );
      expect(service.calls, 0);
    });
  });
}
