import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';

/// One numbered step of a routine.
class RoutineStep {
  const RoutineStep({required this.number, required this.product});

  /// 1-based position within its routine.
  final int number;
  final Product product;

  ProductCategory get category => product.category;
}

/// A morning and a night routine for one user (Figma 08).
class Routine {
  const Routine({
    required this.morning,
    required this.night,
    this.concerns = const [],
    this.budget,
  });

  final List<RoutineStep> morning;
  final List<RoutineStep> night;

  /// What the user said bothers them, for the subtitle.
  final List<SkinConcern> concerns;
  final BudgetBand? budget;

  List<RoutineStep> stepsFor(RoutineTime time) =>
      time == RoutineTime.morning ? morning : night;

  /// The prices of the steps shown for [time] ("Rs 5,050 total").
  int totalFor(RoutineTime time) =>
      stepsFor(time).fold(0, (sum, step) => sum + step.product.pricePkr);

  /// What the products cost to buy once: a product used morning and night is
  /// counted once. This is what the budget is checked against.
  int get monthlyCostPkr {
    final unique = {
      for (final s in [...morning, ...night]) s.product,
    };
    return unique.fold(0, (sum, p) => sum + p.pricePkr);
  }

  /// About 75 seconds a step, rounded up.
  int minutesFor(RoutineTime time) => (stepsFor(time).length * 1.25).ceil();

  bool get fitsBudget {
    final limit = budget?.maxMonthlyPkr;
    return limit == null || monthlyCostPkr <= limit;
  }
}
