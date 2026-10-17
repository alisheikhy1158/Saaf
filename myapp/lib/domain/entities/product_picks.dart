/// One product Saaf AI chose for the user, and why.
class ProductPick {
  const ProductPick({required this.productId, required this.reason});

  final String productId;
  final String reason;
}

/// The products Saaf AI chose from the app's own catalogue for this user's
/// skin, scan and budget. Only ids of products the safety answers allow are
/// ever offered to it, so a pick can never be an unsafe or made-up product.
class ProductPicks {
  const ProductPicks({required this.summary, required this.picks});

  /// One or two sentences about the routine as a whole.
  final String summary;
  final List<ProductPick> picks;

  Set<String> get productIds => {for (final p in picks) p.productId};

  String? reasonFor(String productId) {
    for (final pick in picks) {
      if (pick.productId == productId) return pick.reason;
    }
    return null;
  }
}
