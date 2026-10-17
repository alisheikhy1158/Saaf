import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

/// Saaf AI's cosmetic estimate of the four measures from one front photo, with
/// how sure it is about each ([SkinMetric.confidence]). When it could not judge
/// the photo, [usable] is false and [problem] says why.
class AiSkinEstimate {
  const AiSkinEstimate({
    required this.usable,
    this.problem = '',
    this.summary = '',
    this.metrics = const [],
  });

  final bool usable;
  final String problem;
  final String summary;

  /// In the results screen's order.
  final List<SkinMetric> metrics;

  /// The scan's results from this estimate.
  SkinAnalysis toAnalysis({required String scanId, required DateTime takenAt}) {
    const order = SkinMetricKind.values;
    final sorted = [...metrics]
      ..sort((a, b) => order.indexOf(a.kind).compareTo(order.indexOf(b.kind)));
    return SkinAnalysis(
      scanId: scanId,
      takenAt: takenAt,
      metrics: sorted,
      source: AnalysisSource.aiPhoto,
      summary: summary.isEmpty ? null : summary,
    );
  }
}
