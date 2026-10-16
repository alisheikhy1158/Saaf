import 'dart:async';

import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';

/// What the pretend store does when asked to buy.
enum PurchaseOutcome { succeed, cancel, fail }

/// PLACEHOLDER store for Chrome, tests and debug builds: "buys" instantly and
/// costs nothing. It must never reach a release build (see
/// `subscription_providers.dart`); RevenueCat replaces it in Phase 9.
class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({this.outcome = PurchaseOutcome.succeed});

  final PurchaseOutcome outcome;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  bool _pro = false;

  static const _yearly = SubscriptionPlan(
    id: 'saaf_pro_yearly',
    period: PlanPeriod.yearly,
    priceText: 'Rs 3,999',
    pricePerMonthText: 'Rs 333',
    priceValue: 3999,
    trialDays: 7,
  );
  static const _monthly = SubscriptionPlan(
    id: 'saaf_pro_monthly',
    period: PlanPeriod.monthly,
    priceText: 'Rs 599',
    priceValue: 599,
  );

  @override
  Future<Result<List<SubscriptionPlan>>> plans() async =>
      const Ok([_yearly, _monthly]);

  @override
  Future<Result<void>> purchase(SubscriptionPlan plan) async {
    switch (outcome) {
      case PurchaseOutcome.cancel:
        return const Err(PurchaseCancelled());
      case PurchaseOutcome.fail:
        return const Err(NetworkFailure());
      case PurchaseOutcome.succeed:
        _pro = true;
        _changes.add(true);
        return const Ok<void>(null);
    }
  }

  @override
  Future<Result<bool>> restore() async => Ok(_pro);

  @override
  Future<bool> isPro() async => _pro;

  @override
  Stream<bool> get proChanges => _changes.stream;
}
