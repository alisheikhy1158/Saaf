import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/fake_subscription_repository.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';
import 'package:saaf/domain/usecases/purchase_plan.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';

part 'subscription_providers.g.dart';

/// Until RevenueCat is connected (PLAN Phase 9), debug builds and
/// `--dart-define=FAKE_PURCHASES=true` use a pretend store that "buys" for free.
/// A release build without it gets a store that offers nothing, so the fake can
/// never hand out Pro by accident.
@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) =>
    kDebugMode || Env.fakePurchases
    ? FakeSubscriptionRepository()
    : const UnavailableSubscriptionRepository();

/// Offers nothing and sells nothing (a release build with no store connected).
class UnavailableSubscriptionRepository implements SubscriptionRepository {
  const UnavailableSubscriptionRepository();

  @override
  Future<Result<List<SubscriptionPlan>>> plans() async => const Ok([]);

  @override
  Future<Result<void>> purchase(SubscriptionPlan plan) async =>
      const Err(UnknownFailure('store-unavailable'));

  @override
  Future<Result<bool>> restore() async => const Ok(false);

  @override
  Future<bool> isPro() async => false;

  @override
  Stream<bool> get proChanges => const Stream.empty();
}

@Riverpod(keepAlive: true)
PurchasePlan purchasePlan(Ref ref) =>
    PurchasePlan(ref.watch(subscriptionRepositoryProvider));

@Riverpod(keepAlive: true)
RestorePurchases restorePurchases(Ref ref) =>
    RestorePurchases(ref.watch(subscriptionRepositoryProvider));

/// Whether the user has Saaf Pro (the `pro` entitlement). Free until the store
/// says otherwise, and it follows the store's changes (purchase, restore,
/// expiry).
@Riverpod(keepAlive: true)
class ProStatus extends _$ProStatus {
  @override
  bool build() {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final subscription = repository.proChanges.listen((isPro) => state = isPro);
    ref.onDispose(subscription.cancel);
    unawaited(
      repository.isPro().then((isPro) {
        if (ref.mounted) state = isPro;
      }),
    );
    return false;
  }
}

/// The plans on offer, as the store lists them (prices already formatted).
@Riverpod(retry: noAutoRetry)
Future<List<SubscriptionPlan>> subscriptionPlans(Ref ref) async {
  final result = await ref.watch(subscriptionRepositoryProvider).plans();
  return result.when(ok: (plans) => plans, err: (failure) => throw failure);
}
