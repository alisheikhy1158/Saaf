import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

/// Reads and writes Saaf AI's skin estimate as JSON: the shape our server sends
/// (`/v1/skin`) and the shape the phone keeps it in. Null when it is not one.
abstract final class AiSkinEstimateJson {
  static AiSkinEstimate? decode(Object? json) {
    if (json is! Map<String, Object?>) return null;
    if (json['usable'] != true) {
      final problem = json['problem'];
      return AiSkinEstimate(
        usable: false,
        problem: problem is String ? problem.trim() : '',
      );
    }
    final metrics = <SkinMetric>[];
    if (json['metrics'] case final Map<String, Object?> map) {
      for (final kind in SkinMetricKind.values) {
        if (map[kind.name]
            case {
                  'score': final num score,
                  'confidence': final String confidence,
                } &&
                final Map<String, Object?> item) {
          final seen = item['seen'];
          metrics.add(
            SkinMetric(
              kind: kind,
              amount: score.toDouble().clamp(0, 1),
              confidence:
                  Confidence.values.asNameMap()[confidence] ?? Confidence.low,
              seen: seen is String && seen.trim().isNotEmpty
                  ? seen.trim()
                  : null,
            ),
          );
        }
      }
    }
    // All four, or it is not an estimate the screen can show.
    if (metrics.length != SkinMetricKind.values.length) return null;
    final summary = json['summary'];
    return AiSkinEstimate(
      usable: true,
      summary: summary is String ? summary.trim() : '',
      metrics: metrics,
    );
  }

  static Map<String, Object?> encode(AiSkinEstimate estimate) => {
    'usable': estimate.usable,
    'problem': estimate.problem,
    'summary': estimate.summary,
    'metrics': {
      for (final m in estimate.metrics)
        m.kind.name: {
          'score': m.amount,
          'confidence': (m.confidence ?? Confidence.low).name,
          'seen': m.seen ?? '',
        },
    },
  };
}
