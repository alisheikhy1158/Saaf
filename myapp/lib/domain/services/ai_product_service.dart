import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/product_picks.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

/// Saaf AI's help with products, through our own server (like the coach).
abstract interface class AiProductService {
  /// Chooses the best of [candidates] for the user. [scan] holds the latest
  /// face-scan scores (0–1), empty without a scan.
  Future<Result<ProductPicks>> pickProducts({
    required AiContext context,
    required List<Product> candidates,
    Map<SkinMetricKind, double> scan = const {},
  });

  /// Finds out what a product is (searching the web) and whether it suits the
  /// user. Not finding it is an answer ([ProductInsight.notFound]), not a
  /// failure.
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  });
}
