import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/fake_subscription_repository.dart';
import 'package:saaf/data/repositories/revenuecat_subscription_repository.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';
import 'package:saaf/domain/usecases/purchase_plan.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';

part 'subscription_providers.g.dart';

/// With a RevenueCat key for this phone, Saaf Pro is sold through Google Play
/// or the App Store (card, Google Pay, Apple Pay in the store's own sheet).
/// Without one, debug builds and `--dart-define=FAKE_PURCHASES=true` use a
/// pretend store that "buys" for free, and a release build gets a store that
/// offers nothing, so the fake can never hand out Pro by accident.
@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  final key = revenueCatKeyFor(
    defaultTargetPlatform,
    isWeb: kIsWeb,
    android: Env.revenueCatAndroidKey,
    ios: Env.revenueCatIosKey,
  );
  if (key != null) return RevenueCatSubscriptionRepository(key);
  return kDebugMode || Env.fakePurchases
      ? FakeSubscriptionRepository()
      : const UnavailableSubscriptionRepository();
}

/// Keeps the store's user the same as the signed-in Saaf user. Watched by the
/// app root.
@Riverpod(keepAlive: true)
void subscriptionUserSync(Ref ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  ref.listen(authSessionControllerProvider, (previous, next) {
    if (previous?.userId != next?.userId) {
      unawaited(repository.setUser(next?.userId));
    }
  }, fireImmediately: true);
}

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

  @override
  Future<void> setUser(String? userId) async {}
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
