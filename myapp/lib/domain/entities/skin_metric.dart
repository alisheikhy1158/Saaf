/// The four things the results screen measures (Figma 07 "Concerns").
enum SkinMetricKind {
  darkSpots,
  breakouts,
  oiliness,
  hydration;

  /// For hydration more is good; for the other three more is a bigger concern.
  bool get higherIsBetter => this == hydration;
}

/// The word shown next to a bar: mild / moderate / high for a concern,
/// low / fair / good for hydration.
enum SkinRating { mild, moderate, high, low, fair, good }

/// One measure of the skin, [amount] from 0 to 1.
class SkinMetric {
  const SkinMetric({required this.kind, required this.amount})
    : assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');

  final SkinMetricKind kind;
  final double amount;

  static const double _firstStep = 0.4;
  static const double _secondStep = 0.7;

  /// How much attention this area needs, 0 (none) to 1 (a lot).
  double get need => kind.higherIsBetter ? 1 - amount : amount;

  SkinRating get rating {
    if (kind.higherIsBetter) {
      if (amount >= _secondStep) return SkinRating.good;
      if (amount >= _firstStep) return SkinRating.fair;
      return SkinRating.low;
    }
    if (amount >= _secondStep) return SkinRating.high;
    if (amount >= _firstStep) return SkinRating.moderate;
    return SkinRating.mild;
  }
}
