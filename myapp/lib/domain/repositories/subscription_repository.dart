import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';

/// Saaf Pro: what can be bought and whether the user has it. The real
/// implementation is RevenueCat on top of the App Store and Google Play
/// (PLAN Phase 9); entitlement `pro` is the only thing the app checks.
abstract interface class SubscriptionRepository {
  Future<Result<List<SubscriptionPlan>>> plans();

  /// Buys [plan]. The user cancelling the store sheet is `PurchaseCancelled`.
  Future<Result<void>> purchase(SubscriptionPlan plan);

  /// Asks the store for earlier purchases (required by the stores). True when a
  /// Pro subscription was found.
  Future<Result<bool>> restore();

  Future<bool> isPro();

  /// Emits whenever the Pro state changes.
  Stream<bool> get proChanges;
}
