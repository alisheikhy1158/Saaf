// Covers: Saaf AI choosing products and looking products up (store-compliance
// §5) — only after consent, only products the safety answers allow, and the
// safety answers themselves never leave the phone
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/repositories/real_product_catalog.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/product_picks.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/look_up_product.dart';
import 'package:saaf/domain/usecases/pick_products.dart';

class _Service implements AiProductService {
  int calls = 0;
  AiContext? context;
  List<Product>? candidates;
  Map<SkinMetricKind, double>? scan;
  ProductQuery? query;

  @override
  Future<Result<ProductPicks>> pickProducts({
    required AiContext context,
    required List<Product> candidates,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    calls++;
    this.context = context;
    this.candidates = candidates;
    this.scan = scan;
    return Ok(
      ProductPicks(
        summary: 'Gentle picks.',
        picks: [ProductPick(productId: candidates.first.id, reason: 'Gentle.')],
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

  group('PickProducts', () {
    Future<Result<ProductPicks>> pick({
      bool consent = true,
      SkinProfile profile = _pregnantWithAcne,
      List<Product> catalog = RealProductCatalog.products,
      SkinAnalysis? analysis,
    }) async =>
        PickProducts(
          service: service,
          consent: await _consent(given: consent),
        )(
          profile: profile,
          catalog: catalog,
          analysis: analysis,
          languageCode: 'ur',
        );

    test('nothing is sent without consent', () async {
      expect(
        (await pick(consent: false)).failureOrNull,
        const ConsentMissing(),
      );
      expect(service.calls, 0);
    });

    test('sends only products the safety answers allow', () async {
      await pick();
      expect(service.candidates, isNotEmpty);
      expect(service.candidates!.any((p) => p.avoidInPregnancy), isFalse);
    });

    test(
      'the skin facts and language go along, the safety answers do not',
      () async {
        await pick();
        final context = service.context!;
        expect(context.languageCode, 'ur');
        expect(context.skinType, SkinType.oily);
        expect(context.concerns, {SkinConcern.acne, SkinConcern.darkSpots});
        expect(context.budget, BudgetBand.balanced);
        // AiContext has no field for the safety answers at all.
      },
    );

    test('the latest scan scores go along when there is a scan', () async {
      await pick(analysis: _analysis);
      expect(service.scan, {
        SkinMetricKind.darkSpots: 0.6,
        SkinMetricKind.hydration: 0.4,
      });
      await pick();
      expect(service.scan, isEmpty);
    });

    test('with no products to choose from, nothing is sent', () async {
      expect(
        (await pick(catalog: const [])).failureOrNull,
        isA<ValidationFailure>(),
      );
      expect(service.calls, 0);
    });

    test('the answer comes back', () async {
      final picks = (await pick()).valueOrNull!;
      expect(picks.summary, 'Gentle picks.');
      expect(picks.productIds, hasLength(1));
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
