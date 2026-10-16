import 'package:saaf/domain/entities/skin_metric.dart';

/// How the headline on the results screen reads.
enum SkinTone { good, fair, needsCare }

/// The result of a face scan (Figma 07): four measures, one score and the two
/// areas to work on first. Cosmetic screening only, never a diagnosis.
class SkinAnalysis {
  const SkinAnalysis({
    required this.scanId,
    required this.takenAt,
    required this.metrics,
  });

  final String scanId;
  final DateTime takenAt;

  /// In display order.
  final List<SkinMetric> metrics;

  /// 0–100. Problems cost up to 40 points between them (their average), a dry
  /// skin up to 20 more. A perfect skin is 100; the worst possible is 40.
  int get score {
    final concerns = metrics.where((m) => !m.kind.higherIsBetter).toList();
    final hydration = metrics.where((m) => m.kind.higherIsBetter).toList();
    final concernAverage = concerns.isEmpty
        ? 0.0
        : concerns.map((m) => m.amount).reduce((a, b) => a + b) /
              concerns.length;
    final dryness = hydration.isEmpty
        ? 0.0
        : hydration.map((m) => 1 - m.amount).reduce((a, b) => a + b) /
              hydration.length;
    final raw = 100 - 40 * concernAverage - 20 * dryness;
    return raw.round().clamp(0, 100);
  }

  /// The two areas that need the most attention, biggest first. Ties keep the
  /// on-screen order.
  List<SkinMetric> get focus {
    final indexed = metrics.indexed.toList()
      ..sort((a, b) {
        final byNeed = b.$2.need.compareTo(a.$2.need);
        return byNeed != 0 ? byNeed : a.$1.compareTo(b.$1);
      });
    return [for (final (_, metric) in indexed.take(2)) metric];
  }

  SkinTone get tone => switch (score) {
    >= 75 => SkinTone.good,
    >= 50 => SkinTone.fair,
    _ => SkinTone.needsCare,
  };
}
