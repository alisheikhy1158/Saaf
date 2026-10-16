import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

/// The words for the four measures and their ratings.
extension SkinMetricKindText on SkinMetricKind {
  String label(AppLocalizations l10n) => switch (this) {
    SkinMetricKind.darkSpots => l10n.metricDarkSpots,
    SkinMetricKind.breakouts => l10n.metricBreakouts,
    SkinMetricKind.oiliness => l10n.metricOiliness,
    SkinMetricKind.hydration => l10n.metricHydration,
  };
}

extension SkinRatingText on SkinRating {
  String label(AppLocalizations l10n) => switch (this) {
    SkinRating.mild => l10n.ratingMild,
    SkinRating.moderate => l10n.ratingModerate,
    SkinRating.high => l10n.ratingHigh,
    SkinRating.low => l10n.ratingLow,
    SkinRating.fair => l10n.ratingFair,
    SkinRating.good => l10n.ratingGood,
  };
}
