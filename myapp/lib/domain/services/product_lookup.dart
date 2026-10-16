import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/scanned_product.dart';

/// Finds a product by its barcode. Success with null means "no such product".
abstract interface class ProductLookup {
  Future<Result<ScannedProduct?>> byBarcode(String barcode);
}
