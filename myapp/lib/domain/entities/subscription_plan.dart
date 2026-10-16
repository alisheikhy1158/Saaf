enum PlanPeriod { monthly, yearly }

/// One way to subscribe to Saaf Pro. Prices come from the store already
/// formatted for the user's country ([priceText]); [priceValue] is only used to
/// work out how much a yearly plan saves (store-compliance §4: never hard-code
/// prices).
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.period,
    required this.priceText,
    required this.priceValue,
    this.pricePerMonthText,
    this.trialDays = 0,
  });

  final String id;
  final PlanPeriod period;

  /// "Rs 3,999", as the store formats it.
  final String priceText;
  final double priceValue;

  /// "Rs 333": what a month costs on a yearly plan, as the store formats it.
  final String? pricePerMonthText;

  /// Free trial length; 0 when there is none.
  final int trialDays;

  bool get hasTrial => trialDays > 0;
}

/// How much cheaper (in whole percent) the [yearly] plan is than paying
/// [monthly] twelve times, or null when it is not cheaper or cannot be worked out.
int? savePercent({
  required SubscriptionPlan yearly,
  required SubscriptionPlan monthly,
}) {
  if (yearly.priceValue <= 0 || monthly.priceValue <= 0) return null;
  final percent = ((1 - yearly.priceValue / (monthly.priceValue * 12)) * 100)
      .round();
  return percent > 0 ? percent : null;
}
