import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

/// Saaf AI's help with products, through our own server (like the coach).
abstract interface class AiProductService {
  /// Researches a routine on the web for the user (products sold in Pakistan,
  /// real reviews) and says whether to keep, replace or stop each of
  /// [currentProducts]. [scan] holds the latest face-scan scores (0–1), empty
  /// without a scan.
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<String> currentProducts,
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
