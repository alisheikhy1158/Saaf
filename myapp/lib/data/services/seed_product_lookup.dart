import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/scanned_product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/product_lookup.dart';

/// PLACEHOLDER lookup with one demo product (the serum on the Figma screen), so
/// the result screen can be built and tested. Barcode scanning and the real
/// product / price service come in Phase 8 (see handoff.md). Store names,
/// prices and links here are made up.
class SeedProductLookup implements ProductLookup {
  SeedProductLookup({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// The barcode that finds the demo product.
  static const String demoBarcode = '8964000123456';

  static const Product _serum = Product(
    id: 'demo-niacinamide-zinc',
    name: 'Niacinamide 10% + Zinc Serum',
    category: ProductCategory.treatment,
    pricePkr: 1450,
    times: {RoutineTime.morning, RoutineTime.night},
    skinTypes: {SkinType.oily},
    targets: {SkinConcern.acne, SkinConcern.oiliness},
    ingredients: {Ingredient.niacinamide, Ingredient.zinc},
    fragranceFree: true,
  );

  @override
  Future<Result<ScannedProduct?>> byBarcode(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) return const Err(ValidationFailure('barcode'));
    if (code != demoBarcode) return const Ok<ScannedProduct?>(null);

    return Ok(
      ScannedProduct(
        barcode: code,
        brand: 'LUMÉ',
        name: _serum.name,
        product: _serum,
        pricesAsOf: _now(),
        offers: const [
          ProductOffer(
            store: 'Daraz',
            note: 'Lowest price · 2–4 days',
            pricePkr: 1450,
            url: 'https://example.com/shop/daraz',
            isLowest: true,
          ),
          ProductOffer(
            store: 'Beauty store, F-7',
            note: 'In stock nearby',
            pricePkr: 1520,
            url: 'https://example.com/shop/beauty-store',
          ),
          ProductOffer(
            store: 'Online pharmacy',
            note: 'Next-day delivery',
            pricePkr: 1600,
            url: 'https://example.com/shop/pharmacy',
          ),
        ],
      ),
    );
  }
}
