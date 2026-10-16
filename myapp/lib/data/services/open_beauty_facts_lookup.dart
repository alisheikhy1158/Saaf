import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/services/product_lookup.dart';
import 'package:saaf/domain/usecases/read_ingredients.dart';

/// Finds a product by its barcode in Open Beauty Facts, the free open database
/// of cosmetics (world.openbeautyfacts.org). Coverage varies: a barcode that is
/// not there is reported as "not found", never as an error.
///
/// Only the barcode is sent; nothing about the user. The database has no
/// prices, so the shop offers are search links (Daraz, Google) without a price.
class OpenBeautyFactsLookup implements ProductLookup {
  OpenBeautyFactsLookup({
    http.Client? client,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 12),
    this.userAgent = 'Saaf/1.0 (Flutter app, skincare coach; Pakistan)',
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _now;
  final Duration timeout;

  /// The open database asks every app to say who it is.
  final String userAgent;

  static const _reader = IngredientReader();
  static const _host = 'world.openbeautyfacts.org';

  /// EAN-8, UPC-A, EAN-13 and ITF-14 barcodes are 8 to 14 digits.
  static final _barcode = RegExp(r'^\d{8,14}$');

  @override
  Future<Result<ScannedProduct?>> byBarcode(String barcode) async {
    final code = barcode.trim();
    if (!_barcode.hasMatch(code)) {
      return const Err(ValidationFailure('barcode'));
    }

    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.https(_host, '/api/v2/product/$code.json', const {
              'fields':
                  'code,product_name,brands,ingredients_text,categories_tags',
            }),
            headers: {'User-Agent': userAgent},
          )
          .timeout(timeout);
    } on Object {
      // No connection, a slow server, a closed client: all "try again".
      return const Err(NetworkFailure());
    }

    if (response.statusCode == 404) return const Ok<ScannedProduct?>(null);
    if (response.statusCode != 200) {
      return Err(UnknownFailure('open-beauty-facts-${response.statusCode}'));
    }

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) {
        return const Err(UnknownFailure('open-beauty-facts-shape'));
      }
      if (body['status'] != 1 || body['product'] is! Map) {
        return const Ok<ScannedProduct?>(null);
      }
      return Ok(
        _scanned(code, (body['product'] as Map).cast<String, dynamic>()),
      );
    } on Object {
      return const Err(UnknownFailure('open-beauty-facts-parse'));
    }
  }

  ScannedProduct _scanned(String code, Map<String, dynamic> data) {
    final name = _text(data['product_name']) ?? 'Skincare product';
    final brand = (_text(data['brands']) ?? '').split(',').first.trim();
    final tags = [
      for (final tag in (data['categories_tags'] as List?) ?? const <dynamic>[])
        if (tag is String) tag,
    ];
    final reading = _reader.read(_text(data['ingredients_text']));
    final category = _reader.category(name: name, categoryTags: tags);
    final actives = reading.actives;

    // Trace amounts in a rinse-off cleanser do not make it a strong active.
    final leaveOn = category != ProductCategory.cleanser;
    final retinoid = actives.contains(Ingredient.retinol);
    final strong =
        leaveOn &&
        (retinoid ||
            actives.contains(Ingredient.salicylicAcid) ||
            actives.contains(Ingredient.benzoylPeroxide) ||
            actives.contains(Ingredient.aha) ||
            actives.contains(Ingredient.vitaminC));
    final avoidInPregnancy =
        leaveOn && (retinoid || actives.contains(Ingredient.salicylicAcid));

    final Set<RoutineTime> times;
    if (category == ProductCategory.sunscreen) {
      times = {RoutineTime.morning};
    } else if (leaveOn && (retinoid || actives.contains(Ingredient.aha))) {
      times = {RoutineTime.night};
    } else if (leaveOn && actives.contains(Ingredient.vitaminC)) {
      times = {RoutineTime.morning};
    } else {
      times = {RoutineTime.morning, RoutineTime.night};
    }

    final product = Product(
      id: 'obf-$code',
      name: name,
      category: category,
      pricePkr: 0, // unknown: the open data has no prices
      times: times,
      targets: _targets(actives),
      ingredients: actives,
      isStrongActive: strong,
      avoidInPregnancy: avoidInPregnancy,
      // Only a real list without perfume may be called fragrance-free.
      fragranceFree: reading.knownList && !reading.hasFragrance,
    );

    final search = Uri.encodeQueryComponent('$brand $name'.trim());
    return ScannedProduct(
      barcode: code,
      brand: brand,
      name: name,
      product: product,
      pricesAsOf: _now(),
      offers: [
        ProductOffer(
          store: 'Daraz',
          note: 'Search this product',
          url: 'https://www.daraz.pk/catalog/?q=$search',
        ),
        ProductOffer(
          store: 'Google',
          note: 'Compare shops',
          url: 'https://www.google.com/search?q=$search+price+in+Pakistan',
        ),
      ],
    );
  }

  static Set<SkinConcern> _targets(Set<Ingredient> actives) => {
    if (actives.contains(Ingredient.niacinamide)) ...{
      SkinConcern.oiliness,
      SkinConcern.unevenTone,
    },
    if (actives.contains(Ingredient.vitaminC) ||
        actives.contains(Ingredient.aha)) ...{
      SkinConcern.darkSpots,
      SkinConcern.unevenTone,
    },
    if (actives.contains(Ingredient.retinol) ||
        actives.contains(Ingredient.azelaicAcid)) ...{
      SkinConcern.darkSpots,
      SkinConcern.acne,
      SkinConcern.unevenTone,
    },
    if (actives.contains(Ingredient.salicylicAcid) ||
        actives.contains(Ingredient.benzoylPeroxide) ||
        actives.contains(Ingredient.zinc)) ...{
      SkinConcern.acne,
      SkinConcern.oiliness,
    },
    if (actives.contains(Ingredient.hyaluronicAcid) ||
        actives.contains(Ingredient.ceramides))
      SkinConcern.dryness,
  };

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
