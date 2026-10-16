/// Monthly skincare budget the user picked, in Pakistani rupees. The routine
/// builder only suggests products that fit.
enum BudgetBand {
  essential(3000),
  balanced(6000),
  comfortable(10000),
  premium(null);

  const BudgetBand(this.maxMonthlyPkr);

  /// Upper limit of the band in PKR per month; null means no limit.
  final int? maxMonthlyPkr;
}
