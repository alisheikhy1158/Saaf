// Covers: Figma 10 Product scan result for a REAL product found in the open
// database: shop search links without a made-up price
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/presentation/features/products/screens/product_scan_result_screen.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 17, 9);
}

class _Lookup implements ProductLookup {
  const _Lookup(this.product);
  final ScannedProduct product;

  @override
  Future<Result<ScannedProduct?>> byBarcode(String barcode) async =>
      Ok(product);
}

final _links = FakeExternalLinkService();

final _noPrices = ScannedProduct(
  barcode: '3337875743563',
  brand: 'CeraVe',
  name: 'Hydrating cream-to-foam cleanser',
  pricesAsOf: DateTime(2026, 10, 17),
  product: const Product(
    id: 'obf-3337875743563',
    name: 'Hydrating cream-to-foam cleanser',
    category: ProductCategory.cleanser,
    pricePkr: 0,
    times: {RoutineTime.morning, RoutineTime.night},
    ingredients: {Ingredient.ceramides, Ingredient.hyaluronicAcid},
    fragranceFree: true,
  ),
  offers: const [
    ProductOffer(
      store: 'Daraz',
      note: 'Search this product',
      url: 'https://www.daraz.pk/catalog/?q=CeraVe',
    ),
    ProductOffer(
      store: 'Google',
      note: 'Compare shops',
      url: 'https://www.google.com/search?q=CeraVe',
    ),
  ],
);

Future<void> _open(WidgetTester tester) async {
  final overrides = <Override>[
    clockProvider.overrideWithValue(_Clock()),
    productLookupProvider.overrideWithValue(_Lookup(_noPrices)),
    externalLinkServiceProvider.overrideWithValue(_links),
    shareServiceProvider.overrideWithValue(FakeShareService()),
    skinProfileControllerProvider.overrideWithBuild(
      (ref, n) => const SkinProfile(skinType: SkinType.oily),
    ),
    routineProvider.overrideWith(
      (ref) async => const Routine(morning: [], night: []),
    ),
  ];
  await pumpSaaf(
    tester,
    const ProductScanResultScreen(barcode: '3337875743563'),
    scaffold: false,
    overrides: overrides,
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(_links.opened.clear);

  testWidgets('shows the real product and two shops to look in', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('CERAVE'), findsOneWidget);
    expect(find.text('Hydrating cream-to-foam cleanser'), findsOneWidget);
    expect(find.text('Daraz'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('says "Check price" instead of inventing one', (tester) async {
    await _open(tester);
    expect(find.text('Check price'), findsNWidgets(2));
    expect(find.textContaining('Rs 0'), findsNothing);
  });

  testWidgets('does not claim prices were checked today', (tester) async {
    await _open(tester);
    expect(find.text('Prices today'), findsNothing);
    expect(find.text('Prices vary by shop'), findsOneWidget);
  });

  testWidgets('a shop link opens in the phone browser', (tester) async {
    await _open(tester);
    await tester.ensureVisible(find.text('Buy').first);
    await tester.tap(find.text('Buy').first);
    await tester.pump();
    expect(_links.opened.single, contains('daraz.pk'));
  });

  testWidgets('layout is robust at every size', (tester) async {
    for (final size in matrixSizes) {
      await pumpSaaf(
        tester,
        const ProductScanResultScreen(barcode: '3337875743563'),
        scaffold: false,
        size: size,
        overrides: [
          clockProvider.overrideWithValue(_Clock()),
          productLookupProvider.overrideWithValue(_Lookup(_noPrices)),
          externalLinkServiceProvider.overrideWithValue(_links),
          shareServiceProvider.overrideWithValue(FakeShareService()),
          skinProfileControllerProvider.overrideWithBuild(
            (ref, n) => const SkinProfile(),
          ),
          routineProvider.overrideWith(
            (ref) async => const Routine(morning: [], night: []),
          ),
        ],
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });
}
