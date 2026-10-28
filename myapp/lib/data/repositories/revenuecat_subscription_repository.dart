import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';

/// Saaf Pro through RevenueCat, on top of Google Play Billing and the App Store
/// (store-compliance §4, IAP-1). The store's own payment sheet takes the money,
/// with whatever the user has set up there: a card, Google Pay, Apple Pay,
/// carrier billing or store balance. The app never sees payment details.
///
/// Set up in RevenueCat: entitlement [entitlement], current offering with the
/// `$rc_annual` and `$rc_monthly` packages. Only verifiable on a phone build.
class RevenueCatSubscriptionRepository implements SubscriptionRepository {
  RevenueCatSubscriptionRepository(this._apiKey);

  /// The only thing the app checks to unlock Pro.
  static const entitlement = 'pro';

  final String _apiKey;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  Future<void>? _configured;

  /// Starts RevenueCat once, as the signed-in user when there is one.
  Future<void> _ready({String? userId}) => _configured ??= () async {
    final config = PurchasesConfiguration(_apiKey)..appUserID = userId;
    await Purchases.configure(config);
    Purchases.addCustomerInfoUpdateListener(
      (info) => _changes.add(_isPro(info)),
    );
  }();

  static bool _isPro(CustomerInfo info) =>
      info.entitlements.active.containsKey(entitlement);

  @override
  Future<Result<List<SubscriptionPlan>>> plans() => _guard(() async {
    await _ready();
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) return const <SubscriptionPlan>[];
    return [
      for (final package in offering.availablePackages)
        ?planFromStore(
          id: package.identifier,
          type: package.packageType,
          priceText: package.storeProduct.priceString,
          price: package.storeProduct.price,
          pricePerMonthText: package.storeProduct.pricePerMonthString,
          trialDays: switch (package.storeProduct.introductoryPrice) {
            final intro? when intro.price == 0 => trialDaysOf(
              intro.periodUnit,
              intro.periodNumberOfUnits,
            ),
            _ => 0,
          },
        ),
    ];
  });

  @override
  Future<Result<void>> purchase(SubscriptionPlan plan) => _guard(() async {
    await _ready();
    final offering = (await Purchases.getOfferings()).current;
    final package = offering?.availablePackages
        .where((p) => p.identifier == plan.id)
        .firstOrNull;
    if (package == null) throw const UnknownFailure('store-no-package');
    final result = await Purchases.purchase(PurchaseParams.package(package));
    _changes.add(_isPro(result.customerInfo));
  });

  @override
  Future<Result<bool>> restore() => _guard(() async {
    await _ready();
    final pro = _isPro(await Purchases.restorePurchases());
    _changes.add(pro);
    return pro;
  });

  @override
  Future<bool> isPro() async {
    final result = await _guard(() async {
      await _ready();
      return _isPro(await Purchases.getCustomerInfo());
    });
    return result.valueOrNull ?? false;
  }

  @override
  Stream<bool> get proChanges => _changes.stream;

  /// Links purchases to the Saaf account (so they follow the user to a new
  /// phone), or back to an anonymous store user after sign-out.
  @override
  Future<void> setUser(String? userId) async {
    try {
      if (_configured == null) {
        await _ready(userId: userId);
        return;
      }
      await _ready();
      final info = userId == null
          ? await Purchases.logOut()
          : (await Purchases.logIn(userId)).customerInfo;
      _changes.add(_isPro(info));
    } on Object {
      // Logging out an anonymous user throws; nothing to do.
    }
  }

  static Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok(await run());
    } on PlatformException catch (e) {
      return Err(failureFromStore(e));
    } on Failure catch (f) {
      return Err(f);
    } on Object {
      return const Err(UnknownFailure('store'));
    }
  }
}

/// A Saaf Pro plan from a store package; null for kinds Saaf does not sell.
SubscriptionPlan? planFromStore({
  required String id,
  required PackageType type,
  required String priceText,
  required double price,
  required int trialDays,
  String? pricePerMonthText,
}) => switch (type) {
  PackageType.annual => SubscriptionPlan(
    id: id,
    period: PlanPeriod.yearly,
    priceText: priceText,
    priceValue: price,
    pricePerMonthText: pricePerMonthText,
    trialDays: trialDays,
  ),
  PackageType.monthly => SubscriptionPlan(
    id: id,
    period: PlanPeriod.monthly,
    priceText: priceText,
    priceValue: price,
    trialDays: trialDays,
  ),
  _ => null,
};

/// A free trial's length in days.
int trialDaysOf(PeriodUnit unit, int count) => switch (unit) {
  PeriodUnit.day => count,
  PeriodUnit.week => count * 7,
  PeriodUnit.month => count * 30,
  PeriodUnit.year => count * 365,
  PeriodUnit.unknown => 0,
};

/// What a store error means for the user.
Failure failureFromStore(PlatformException error) =>
    switch (PurchasesErrorHelper.getErrorCode(error)) {
      PurchasesErrorCode.purchaseCancelledError => const PurchaseCancelled(),
      PurchasesErrorCode.networkError ||
      PurchasesErrorCode.offlineConnectionError => const NetworkFailure(),
      final code => UnknownFailure('store-${code.name}'),
    };

/// The RevenueCat key for this phone, or null when there is no store to use
/// (web, desktop, or the key was not set in Codemagic).
String? revenueCatKeyFor(
  TargetPlatform platform, {
  required bool isWeb,
  required String android,
  required String ios,
}) {
  if (isWeb) return null;
  final key = switch (platform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS => ios,
    _ => '',
  };
  return key.isEmpty ? null : key;
}
