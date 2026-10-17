import 'dart:typed_data';

/// What the user gives Saaf AI to look a product up with.
sealed class ProductQuery {
  const ProductQuery();
}

/// A photo of the product's label (never of a face).
final class ProductPhotoQuery extends ProductQuery {
  const ProductPhotoQuery(this.bytes);
  final Uint8List bytes;
}

/// A barcode number nobody's database knew.
final class ProductBarcodeQuery extends ProductQuery {
  const ProductBarcodeQuery(this.digits);
  final String digits;

  @override
  bool operator ==(Object other) =>
      other is ProductBarcodeQuery && other.digits == digits;

  @override
  int get hashCode => digits.hashCode;
}

/// The text of a QR code on the pack (usually a link to the brand's page).
final class ProductQrQuery extends ProductQuery {
  const ProductQrQuery(this.text);
  final String text;

  @override
  bool operator ==(Object other) =>
      other is ProductQrQuery && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// What Saaf AI found about a product, written for this user's skin.
class ProductInsight {
  const ProductInsight({
    required this.text,
    required this.webChecked,
    this.title,
  }) : found = true;

  /// Saaf AI could not tell which product it is.
  const ProductInsight.notFound()
    : found = false,
      title = null,
      text = '',
      webChecked = false;

  final bool found;

  /// Brand and product name, when known.
  final String? title;

  /// The answer, in the coach's light formatting (see `parseAiText`).
  final String text;

  /// False when the web search failed and the answer is from what the model
  /// already knew.
  final bool webChecked;
}
