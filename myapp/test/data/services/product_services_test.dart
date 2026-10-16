// Covers: 10 Product scan result — demo product lookup (PLACEHOLDER) and external
// Buy links (store-compliance: open in the browser, http(s) only)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/plugin_external_link_service.dart';
import 'package:saaf/data/services/seed_product_lookup.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/ingredient.dart';

void main() {
  group('SeedProductLookup', () {
    final lookup = SeedProductLookup(now: () => DateTime(2026, 10, 15, 9));

    test('the demo barcode finds the serum from the Figma screen', () async {
      final found = (await lookup.byBarcode(
        SeedProductLookup.demoBarcode,
      )).valueOrNull!;
      expect(found.brand, 'LUMÉ');
      expect(found.name, 'Niacinamide 10% + Zinc Serum');
      expect(found.product.ingredients, contains(Ingredient.niacinamide));
      expect(found.pricesAsOf, DateTime(2026, 10, 15, 9));
    });

    test('offers are cheapest first, with the cheapest marked', () async {
      final found = (await lookup.byBarcode(
        SeedProductLookup.demoBarcode,
      )).valueOrNull!;
      expect(found.offers.map((o) => o.pricePkr), [1450, 1520, 1600]);
      expect(found.offers.map((o) => o.isLowest), [true, false, false]);
      expect(found.lowestPricePkr, 1450);
    });

    test('every link is a safe https address', () async {
      final found = (await lookup.byBarcode(
        SeedProductLookup.demoBarcode,
      )).valueOrNull!;
      for (final offer in found.offers) {
        expect(Uri.parse(offer.url).scheme, 'https');
      }
    });

    test('an unknown barcode is not an error, just not found', () async {
      final result = await lookup.byBarcode('0000000000000');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a barcode with spaces around it is still found', () async {
      final result = await lookup.byBarcode(
        ' ${SeedProductLookup.demoBarcode} ',
      );
      expect(result.valueOrNull, isNotNull);
    });

    test('an empty barcode is invalid', () async {
      expect(
        (await lookup.byBarcode('  ')).failureOrNull,
        const ValidationFailure('barcode'),
      );
    });
  });

  group('PluginExternalLinkService', () {
    test('opens an https link', () async {
      Uri? opened;
      final service = PluginExternalLinkService(
        launch: (uri) async {
          opened = uri;
          return true;
        },
      );
      expect((await service.open('https://example.com/buy?id=1')).isOk, isTrue);
      expect(opened, Uri.parse('https://example.com/buy?id=1'));
    });

    test('also allows plain http', () async {
      final service = PluginExternalLinkService(launch: (_) async => true);
      expect((await service.open('http://shop.example.pk')).isOk, isTrue);
    });

    test('refuses anything that is not http or https', () async {
      var launched = false;
      final service = PluginExternalLinkService(
        launch: (_) async => launched = true,
      );
      for (final bad in [
        'javascript:alert(1)',
        'file:///etc/passwd',
        'tel:+923001234567',
        'intent://x#Intent;end',
        'example.com',
        '',
        'https://',
      ]) {
        expect(
          (await service.open(bad)).failureOrNull,
          const ValidationFailure('url'),
          reason: bad,
        );
      }
      expect(launched, isFalse);
    });

    test('the phone refusing to open it is a failure, not a crash', () async {
      final service = PluginExternalLinkService(launch: (_) async => false);
      expect(
        (await service.open('https://example.com')).failureOrNull,
        isA<Failure>(),
      );
    });

    test('an exception becomes a failure', () async {
      final service = PluginExternalLinkService(
        launch: (_) async => throw StateError('x'),
      );
      expect(
        (await service.open('https://example.com')).failureOrNull,
        isA<Failure>(),
      );
    });
  });

  test('FakeExternalLinkService remembers what was opened', () async {
    final service = FakeExternalLinkService();
    await service.open('https://example.com');
    expect(service.opened, ['https://example.com']);
  });
}
