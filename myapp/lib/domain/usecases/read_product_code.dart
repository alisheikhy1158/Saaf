/// What a code on a product pack holds.
sealed class ProductCode {
  const ProductCode();
}

/// A product number (EAN/UPC/GTIN), from a barcode or a QR code that carries it.
final class ProductBarcode extends ProductCode {
  const ProductBarcode(this.digits);
  final String digits;

  @override
  bool operator ==(Object other) =>
      other is ProductBarcode && other.digits == digits;

  @override
  int get hashCode => digits.hashCode;

  @override
  String toString() => 'ProductBarcode($digits)';
}

/// Any other QR code (usually a link to the brand's page): only Saaf AI can
/// look it up. It is never opened by the app.
final class ProductQrText extends ProductCode {
  const ProductQrText(this.text);
  final String text;

  @override
  bool operator ==(Object other) =>
      other is ProductQrText && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ProductQrText($text)';
}

/// Reads what the camera saw on a product: a barcode number, a QR code with
/// the product number in it (GS1 Digital Link like `…/01/03337875743563`, or a
/// GS1 DataMatrix / element string `(01)03337875743563…`), or other QR text.
class ReadProductCode {
  const ReadProductCode();

  /// QR text longer than this is cut short.
  static const maxText = 500;

  static final _digits = RegExp(r'^\d{8,14}$');
  static final _digitalLink = RegExp(r'/01/(\d{8,14})(?:[/?#]|$)');
  static final _elementString = RegExp(r'^(?:\(01\)|\x1d?01)(\d{14})');

  ProductCode? call(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (_digits.hasMatch(text)) return ProductBarcode(text);

    final gtin =
        _digitalLink.firstMatch(text)?.group(1) ??
        _elementString.firstMatch(raw.trimLeft())?.group(1);
    if (gtin != null) return ProductBarcode(_shorten(gtin));

    return ProductQrText(
      text.length > maxText ? text.substring(0, maxText) : text,
    );
  }

  /// A 14-digit GTIN starting with 0 is the same product as the 13-digit EAN
  /// printed under ordinary barcodes (the number product databases use).
  static String _shorten(String gtin) =>
      gtin.length == 14 && gtin.startsWith('0') ? gtin.substring(1) : gtin;
}
