import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/services/skin_analyzer.dart';

/// PLACEHOLDER. Real analysis of the three photos needs an on-device model that
/// does not exist yet. Until then this estimates the four bars from what the
/// user told us in the quiz (the photos are not looked at), so the whole flow
/// can be built and tested. It must be replaced before release (see handoff.md),
/// and the screen must not be presented as a measurement until then.
class DemoSkinAnalyzer implements SkinAnalyzer {
  const DemoSkinAnalyzer();

  static const double _floor = 0.05;
  static const double _ceiling = 0.95;

  @override
  Future<Result<SkinAnalysis>> analyze({
    required CompletedScan scan,
    required SkinProfile profile,
  }) async {
    var spots = 0.30;
    var breakouts = 0.25;
    var oil = 0.35;
    var hydration = 0.65;

    for (final concern in profile.concerns) {
      switch (concern) {
        case SkinConcern.darkSpots:
          spots += 0.30;
        case SkinConcern.acne:
          breakouts += 0.35;
        case SkinConcern.oiliness:
          oil += 0.25;
        case SkinConcern.dryness:
          hydration -= 0.30;
        case SkinConcern.unevenTone:
          spots += 0.15;
      }
    }

    switch (profile.skinType) {
      case SkinType.oily:
        oil += 0.20;
        breakouts += 0.05;
      case SkinType.dry:
        oil -= 0.15;
        hydration -= 0.20;
      case SkinType.combination:
        oil += 0.10;
      case SkinType.normal || SkinType.notSure || null:
        break;
    }

    double clamp(double v) => v.clamp(_floor, _ceiling);
    return Ok(
      SkinAnalysis(
        scanId: scan.id,
        takenAt: scan.takenAt,
        metrics: [
          SkinMetric(kind: SkinMetricKind.darkSpots, amount: clamp(spots)),
          SkinMetric(kind: SkinMetricKind.breakouts, amount: clamp(breakouts)),
          SkinMetric(kind: SkinMetricKind.oiliness, amount: clamp(oil)),
          SkinMetric(kind: SkinMetricKind.hydration, amount: clamp(hydration)),
        ],
      ),
    );
  }
}
