// Covers: Figma 10 Product scan result (node 3:446), design.md §10 (external Buy
// links, price "as of"), store-compliance (affiliate disclosure, links open in the
// browser), A11Y-1/2/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/data/services/seed_product_lookup.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/external_link_service.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/presentation/features/products/screens/product_scan_result_screen.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

final _today = DateTime(2026, 10, 15, 9, 41);

/// A routine whose morning has the Vitamin C serum (the Figma clash).
final _withVitaminC = Routine(
  morning: [
    RoutineStep(
      number: 1,
      product: SeedProductCatalog.products.firstWhere(
        (p) => p.id == 'treatment-vitamin-c',
      ),
    ),
  ],
  night: const [],
);

const _noClash = Routine(morning: [], night: []);

class _Lookup implements ProductLookup {
  const _Lookup(this.result);
  final Future<Result<ScannedProduct?>> Function() result;

  @override
  Future<Result<ScannedProduct?>> byBarcode(String barcode) => result();
}

final _fakeLinks = FakeExternalLinkService();
final _fakeShare = FakeShareService();

List<Override> _with({
  SkinProfile profile = const SkinProfile(skinType: SkinType.oily),
  Routine? routine,
  ProductLookup? lookup,
  ExternalLinkService? links,
}) {
  return [
    clockProvider.overrideWithValue(_Clock(_today)),
    productLookupProvider.overrideWithValue(
      lookup ?? SeedProductLookup(now: () => _today),
    ),
    externalLinkServiceProvider.overrideWithValue(links ?? _fakeLinks),
    shareServiceProvider.overrideWithValue(_fakeShare),
    skinProfileControllerProvider.overrideWithBuild((ref, n) => profile),
    routineProvider.overrideWith((ref) async => routine ?? _withVitaminC),
  ];
}

Future<void> _open(
  WidgetTester tester, {
  String? barcode = SeedProductLookup.demoBarcode,
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    ProductScanResultScreen(barcode: barcode),
    scaffold: false,
    size: size,
    overrides: overrides ?? _with(),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() {
    _fakeLinks.opened.clear();
    _fakeShare.shared.clear();
  });

  group('product', () {
    testWidgets('shows the brand, the name and that the barcode matched', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Scan result'), findsOneWidget);
      expect(find.text('Barcode matched'), findsOneWidget);
      expect(find.text('LUMÉ'), findsOneWidget);
      expect(find.text('Niacinamide 10% + Zinc Serum'), findsOneWidget);
    });

    testWidgets('a good match for an oily skin, with its skin types', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Good match for you'), findsOneWidget);
      expect(find.text('Oily · Acne-prone'), findsOneWidget);
    });

    testWidgets('warns about the clash with the Vitamin C in the routine', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Don’t mix with Vitamin C'), findsOneWidget);
      expect(
        find.text('Use this at night if your morning routine has Vitamin C.'),
        findsOneWidget,
      );
    });

    testWidgets('no clash card when the routine has no clashing product', (
      tester,
    ) async {
      await _open(tester, overrides: _with(routine: _noClash));
      expect(find.textContaining('Don’t mix'), findsNothing);
    });

    testWidgets('a product for another skin type says to use it with care', (
      tester,
    ) async {
      await _open(
        tester,
        overrides: _with(profile: const SkinProfile(skinType: SkinType.dry)),
      );
      expect(find.text('Use with care'), findsOneWidget);
      expect(find.text('Check before you use it'), findsOneWidget);
    });

    testWidgets('safety answers can say not recommended', (tester) async {
      final lookup = _Lookup(
        () async => Ok(
          ScannedProduct(
            barcode: '1',
            brand: 'B',
            name: 'Retinol Serum',
            product: const Product(
              id: 'r',
              name: 'Retinol Serum',
              category: ProductCategory.treatment,
              pricePkr: 100,
              times: {RoutineTime.night},
              avoidInPregnancy: true,
              isStrongActive: true,
            ),
            offers: const [],
            pricesAsOf: _today,
          ),
        ),
      );
      await _open(
        tester,
        overrides: _with(
          lookup: lookup,
          profile: const SkinProfile(
            safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
          ),
        ),
      );
      expect(find.text('Not recommended for you'), findsOneWidget);
      expect(find.text('Usually avoided for you'), findsOneWidget);
      expect(find.text('Good match for you'), findsNothing);
    });

    testWidgets('ends with the medical disclaimer', (tester) async {
      await _open(tester);
      await tester.ensureVisible(
        find.text('Ingredient advice is general guidance, not medical advice.'),
      );
      expect(
        find.text('Ingredient advice is general guidance, not medical advice.'),
        findsOneWidget,
      );
    });
  });

  group('where to buy', () {
    testWidgets('lists the stores, cheapest first, with price and note', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Where to buy'), findsOneWidget);
      expect(find.text('Prices today'), findsOneWidget);
      for (final (store, note, price) in [
        ('Daraz', 'Lowest price · 2–4 days', 'Rs 1,450'),
        ('Beauty store, F-7', 'In stock nearby', 'Rs 1,520'),
        ('Online pharmacy', 'Next-day delivery', 'Rs 1,600'),
      ]) {
        await tester.ensureVisible(find.text(store));
        expect(find.text(store), findsOneWidget, reason: store);
        expect(find.text(note), findsOneWidget, reason: note);
        expect(find.text(price), findsOneWidget, reason: price);
      }
      expect(find.text('Buy'), findsNWidgets(3));
    });

    testWidgets('older prices say when they were checked', (tester) async {
      final old = _Lookup(() async {
        final found = await SeedProductLookup(
          now: () => DateTime(2026, 10, 10),
        ).byBarcode(SeedProductLookup.demoBarcode);
        return found;
      });
      await _open(tester, overrides: _with(lookup: old));
      expect(find.text('Prices as of 10 Oct'), findsOneWidget);
      expect(find.text('Prices today'), findsNothing);
    });

    testWidgets('Buy opens that store in the browser', (tester) async {
      await _open(tester);
      await tester.ensureVisible(find.text('Buy').first);
      await tester.tap(find.text('Buy').first);
      await tester.pump();
      expect(_fakeLinks.opened, ['https://example.com/shop/daraz']);
    });

    testWidgets('each Buy button names its store for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(
        find.bySemanticsLabel('Buy from Daraz for Rs 1,450'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('affiliate links are disclosed, plain links are not', (
      tester,
    ) async {
      await _open(tester);
      expect(find.textContaining('commission'), findsNothing);

      final affiliate = _Lookup(
        () async => Ok(
          ScannedProduct(
            barcode: '1',
            brand: 'B',
            name: 'N',
            product: SeedProductCatalog.products.first,
            offers: const [
              ProductOffer(
                store: 'Shop',
                note: 'n',
                pricePkr: 100,
                url: 'https://example.com',
                isAffiliate: true,
              ),
            ],
            pricesAsOf: _today,
          ),
        ),
      );
      await _open(tester, overrides: _with(lookup: affiliate));
      await tester.ensureVisible(find.textContaining('commission'));
      expect(find.textContaining('commission'), findsOneWidget);
    });

    testWidgets('a link that cannot be opened says so', (tester) async {
      final failing = _FailingLinks();
      await _open(tester, overrides: _with(links: failing));
      await tester.ensureVisible(find.text('Buy').first);
      await tester.tap(find.text('Buy').first);
      await tester.pump();
      await tester.pump();
      expect(find.text('We couldn’t open that link.'), findsOneWidget);
    });
  });

  group('share', () {
    testWidgets('shares the name and the lowest price, as text', (
      tester,
    ) async {
      await _open(tester);
      await tester.tap(find.byTooltip('Share this product'));
      await tester.pump();
      expect(_fakeShare.shared, hasLength(1));
      expect(
        _fakeShare.shared.single,
        contains('Niacinamide 10% + Zinc Serum'),
      );
      expect(_fakeShare.shared.single, contains('Rs 1,450'));
    });
  });

  group('states', () {
    testWidgets('opened without a barcode: explains and goes home', (
      tester,
    ) async {
      await _open(tester, barcode: null);
      expect(find.text('No product scanned yet'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('a barcode that is not known', (tester) async {
      await _open(tester, barcode: '0000000000000');
      expect(find.text('We couldn’t find that product'), findsOneWidget);
      expect(
        find.text('Saaf AI can search the web for it instead.'),
        findsOneWidget,
      );
      expect(find.text('Look it up with Saaf AI'), findsOneWidget);
    });

    testWidgets('a lookup that fails can be retried', (tester) async {
      await _open(
        tester,
        overrides: _with(
          lookup: _Lookup(() async => const Err(NetworkFailure())),
        ),
      );
      expect(find.text('We couldn’t load this product'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('the route takes the barcode from the address', (tester) async {
      await pumpSaafApp(
        tester,
        location:
            '/product-scan-result?barcode=${SeedProductLookup.demoBarcode}',
        overrides: _with(),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Niacinamide 10% + Zinc Serum'), findsOneWidget);
    });

    testWidgets('back returns, or goes Home when opened directly', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location:
            '/product-scan-result?barcode=${SeedProductLookup.demoBarcode}',
        overrides: _with(),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const ProductScanResultScreen(
          barcode: SeedProductLookup.demoBarcode,
        ),
        scaffold: false,
        overrides: _with(),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the empty state is robust', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const ProductScanResultScreen(),
        scaffold: false,
        overrides: _with(),
      );
    });
  });
}

class _FailingLinks extends FakeExternalLinkService {
  @override
  Future<Result<void>> open(String url) async =>
      const Err(UnknownFailure('link'));
}
