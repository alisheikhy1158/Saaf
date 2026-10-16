import 'package:saaf/domain/entities/product.dart';

/// One place that sells a product, with its price at [ScannedProduct.pricesAsOf].
class ProductOffer {
  const ProductOffer({
    required this.store,
    required this.note,
    required this.url,
    this.pricePkr,
    this.isLowest = false,
    this.isAffiliate = false,
  });

  final String store;

  /// "Lowest price · 2–4 days", "In stock nearby".
  final String note;

  /// Null when the price is not known (a search link only).
  final int? pricePkr;

  /// Opened in the phone's browser, never inside the app.
  final String url;
  final bool isLowest;

  /// Saaf earns a commission if the user buys through this link (must be
  /// disclosed, store-compliance).
  final bool isAffiliate;
}

/// A product found by its barcode, ready for the result screen.
class ScannedProduct {
  const ScannedProduct({
    required this.barcode,
    required this.brand,
    required this.name,
    required this.product,
    required this.offers,
    required this.pricesAsOf,
  });

  final String barcode;
  final String brand;
  final String name;

  /// What the rules (fit, clashes) look at.
  final Product product;

  /// Cheapest first.
  final List<ProductOffer> offers;

  /// When the prices were checked (shown as "Prices today" / "as of").
  final DateTime pricesAsOf;

  int? get lowestPricePkr {
    final prices = [
      for (final offer in offers)
        if (offer.pricePkr != null) offer.pricePkr!,
    ];
    return prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
  }

  /// At least one offer says what it costs.
  bool get hasPrices => lowestPricePkr != null;

  bool get hasAffiliateLinks => offers.any((o) => o.isAffiliate);
}
