import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';

/// Buys a plan; anything unexpected becomes a failure.
class PurchasePlan {
  const PurchasePlan(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<void>> call(SubscriptionPlan plan) async {
    try {
      return await _repository.purchase(plan);
    } on Object {
      return const Err(UnknownFailure('purchase'));
    }
  }
}

/// "Restore purchases"; anything unexpected becomes a failure.
class RestorePurchases {
  const RestorePurchases(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<bool>> call() async {
    try {
      return await _repository.restore();
    } on Object {
      return const Err(UnknownFailure('restore'));
    }
  }
}
