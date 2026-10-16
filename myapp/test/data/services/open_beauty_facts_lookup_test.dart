// Covers: finding a real product by its barcode in Open Beauty Facts (open
// data), turning its ingredient list into advice, and failing kindly
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/open_beauty_facts_lookup.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';

const _found = {
  'code': '3337875743563',
  'status': 1,
  'product': {
    'brands': 'CeraVe,L’Oréal',
    'categories_tags': ['en:face', 'en:cleansers'],
    'code': '3337875743563',
    'ingredients_text':
        'AQUA/WATER, GLYCERIN, CERAMIDE NP, SALICYLIC ACID, SODIUM HYALURONATE, PHENOXYETHANOL',
    'product_name': 'Hydrating cream-to-foam cleanser',
  },
};

OpenBeautyFactsLookup lookup(http.Client client, {DateTime? now}) =>
    OpenBeautyFactsLookup(
      client: client,
      now: () => now ?? DateTime(2026, 10, 17),
    );

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  group('a product that exists', () {
    test('comes back with brand, name and shop links', () async {
      final result = await lookup(
        MockClient((_) async => json(_found)),
      ).byBarcode('3337875743563');
      final product = result.valueOrNull!;
      expect(product.barcode, '3337875743563');
      expect(product.brand, 'CeraVe');
      expect(product.name, 'Hydrating cream-to-foam cleanser');
      expect(product.offers.map((o) => o.store), ['Daraz', 'Google']);
      expect(product.offers.every((o) => o.pricePkr == null), isTrue);
      expect(product.offers.first.url, startsWith('https://www.daraz.pk/'));
      expect(product.offers.first.url, contains('CeraVe'));
      expect(product.lowestPricePkr, isNull);
    });

    test('the ingredient list becomes advice', () async {
      final product = (await lookup(
        MockClient((_) async => json(_found)),
      ).byBarcode('3337875743563')).valueOrNull!.product;
      expect(product.category, ProductCategory.cleanser);
      expect(product.ingredients, {
        Ingredient.ceramides,
        Ingredient.salicylicAcid,
        Ingredient.hyaluronicAcid,
      });
      // Trace salicylic acid in a rinse-off cleanser is not a strong active.
      expect(product.isStrongActive, isFalse);
      expect(product.avoidInPregnancy, isFalse);
      expect(product.fragranceFree, isTrue);
    });

    test('a leave-on retinol product is a strong night active', () async {
      final body = {
        'status': 1,
        'product': {
          'brands': 'The Ordinary',
          'product_name': 'Retinol 0.5% in Squalane',
          'categories_tags': ['en:serums'],
          'ingredients_text': 'SQUALANE, RETINOL, CAPRYLIC/CAPRIC TRIGLYCERIDE',
        },
      };
      final product = (await lookup(
        MockClient((_) async => json(body)),
      ).byBarcode('769915190878')).valueOrNull!.product;
      expect(product.category, ProductCategory.treatment);
      expect(product.isStrongActive, isTrue);
      expect(product.avoidInPregnancy, isTrue);
      expect(product.times, {RoutineTime.night});
    });

    test('a fragranced product is not fragrance-free', () async {
      final body = {
        'status': 1,
        'product': {
          'brands': 'Nivea',
          'product_name': 'Soft cream',
          'ingredients_text': 'AQUA, GLYCERIN, PARFUM',
        },
      };
      final product = (await lookup(
        MockClient((_) async => json(body)),
      ).byBarcode('4005808256603')).valueOrNull!.product;
      expect(product.fragranceFree, isFalse);
    });

    test('with no ingredient list it is never called fragrance-free', () async {
      final body = {
        'status': 1,
        'product': {'brands': 'Local', 'product_name': 'Some cream'},
      };
      final product = (await lookup(
        MockClient((_) async => json(body)),
      ).byBarcode('8964000123456')).valueOrNull!.product;
      expect(product.fragranceFree, isFalse);
      expect(product.ingredients, isEmpty);
    });

    test('a sunscreen is a morning product', () async {
      final body = {
        'status': 1,
        'product': {
          'brands': 'Neutrogena',
          'product_name': 'Ultra Sheer SPF 50+',
          'categories_tags': ['en:sunscreens'],
          'ingredients_text': 'AQUA, AVOBENZONE',
        },
      };
      final product = (await lookup(
        MockClient((_) async => json(body)),
      ).byBarcode('3574661566190')).valueOrNull!.product;
      expect(product.times, {RoutineTime.morning});
    });

    test('missing names fall back to something readable', () async {
      final body = {
        'status': 1,
        'product': {'code': '1234567890123'},
      };
      final product = (await lookup(
        MockClient((_) async => json(body)),
      ).byBarcode('1234567890123')).valueOrNull!;
      expect(product.name, isNotEmpty);
      expect(product.brand, isA<String>());
    });
  });

  group('a product that does not exist', () {
    test('status 0 means "no such product", not an error', () async {
      final result = await lookup(
        MockClient(
          (_) async =>
              json({'status': 0, 'status_verbose': 'product not found'}),
        ),
      ).byBarcode('0000000000000');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a 404 is also "no such product"', () async {
      final result = await lookup(
        MockClient((_) async => http.Response('', 404)),
      ).byBarcode('0000000000000');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });
  });

  group('when something goes wrong', () {
    test(
      'no connection is a network failure (so the screen can retry)',
      () async {
        final result = await lookup(
          MockClient((_) async => throw http.ClientException('offline')),
        ).byBarcode('3337875743563');
        expect(result.failureOrNull, const NetworkFailure());
      },
    );

    test('a slow server is a network failure', () async {
      final result = await OpenBeautyFactsLookup(
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(seconds: 2));
          return json(_found);
        }),
        timeout: const Duration(milliseconds: 50),
      ).byBarcode('3337875743563');
      expect(result.failureOrNull, const NetworkFailure());
    });

    test('a server error is reported, not hidden', () async {
      final result = await lookup(
        MockClient((_) async => http.Response('oops', 500)),
      ).byBarcode('3337875743563');
      expect(result.failureOrNull, isA<Failure>());
      expect(result.isOk, isFalse);
    });

    test('rubbish that is not JSON is an error, not a crash', () async {
      final result = await lookup(
        MockClient((_) async => http.Response('<html>', 200)),
      ).byBarcode('3337875743563');
      expect(result.isOk, isFalse);
    });
  });

  group('the barcode is checked before anything is sent', () {
    var sent = 0;
    final counting = MockClient((_) async {
      sent++;
      return json(_found);
    });

    for (final bad in [
      '',
      'abc',
      '123',
      '12345678901234567',
      '3337 8757',
      '../x',
    ]) {
      test('"$bad" is refused', () async {
        sent = 0;
        final result = await lookup(counting).byBarcode(bad);
        expect(result.failureOrNull, const ValidationFailure('barcode'));
        expect(sent, 0);
      });
    }

    test('spaces around a good one are fine', () async {
      final result = await lookup(counting).byBarcode(' 3337875743563 ');
      expect(result.isOk, isTrue);
    });
  });

  test('it identifies the app to the open database', () async {
    late http.Request seen;
    await lookup(
      MockClient((request) async {
        seen = request;
        return json(_found);
      }),
    ).byBarcode('3337875743563');
    expect(seen.headers['User-Agent'], contains('Saaf'));
    expect(seen.url.host, 'world.openbeautyfacts.org');
    expect(seen.url.path, '/api/v2/product/3337875743563.json');
  });
}
