import 'package:saaf/domain/entities/product.dart';

/// Where the routine's products come from. Works offline: the app ships a
/// catalogue and may refresh prices when online (OFF-4).
abstract interface class ProductCatalog {
  Future<List<Product>> all();
}
