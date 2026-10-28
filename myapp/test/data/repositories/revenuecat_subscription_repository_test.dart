// Covers: store-compliance §4 (IAP-1) — Saaf Pro is sold through the App Store
// and Google Play via RevenueCat (their payment sheets offer card, Google Pay
// and Apple Pay); prices come from the store, never hard-coded; cancelling the
// store sheet is not an error; the `pro` entitlement is the only thing checked.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/repositories/revenuecat_subscription_repository.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';

void main() {
  group('plans from the store', () {
    test('a yearly package keeps the store price and its monthly price', () {
      final plan = planFromStore(
        id: r'$rc_annual',
        type: PackageType.annual,
        priceText: 'Rs 3,999.00',
        price: 3999,
        pricePerMonthText: 'Rs 333.25',
        trialDays: 7,
      );
      expect(plan?.period, PlanPeriod.yearly);
      expect(plan?.priceText, 'Rs 3,999.00');
      expect(plan?.pricePerMonthText, 'Rs 333.25');
      expect(plan?.trialDays, 7);
    });

    test('a monthly package has no monthly-equivalent line', () {
      final plan = planFromStore(
        id: r'$rc_monthly',
        type: PackageType.monthly,
        priceText: 'Rs 599.00',
        price: 599,
        pricePerMonthText: 'Rs 599.00',
        trialDays: 0,
      );
      expect(plan?.period, PlanPeriod.monthly);
      expect(plan?.pricePerMonthText, isNull);
    });

    test('other package kinds are not offered', () {
      expect(
        planFromStore(
          id: 'lifetime',
          type: PackageType.lifetime,
          priceText: 'Rs 9,999',
          price: 9999,
          trialDays: 0,
        ),
        isNull,
      );
    });

    test('a free trial is read from the store in days', () {
      expect(trialDaysOf(PeriodUnit.day, 3), 3);
      expect(trialDaysOf(PeriodUnit.week, 1), 7);
      expect(trialDaysOf(PeriodUnit.month, 1), 30);
      expect(trialDaysOf(PeriodUnit.unknown, 1), 0);
    });
  });

  group('store errors', () {
    PlatformException error(PurchasesErrorCode code) =>
        PlatformException(code: '${code.index}');

    test('closing the payment sheet is a cancel, not an error', () {
      expect(
        failureFromStore(error(PurchasesErrorCode.purchaseCancelledError)),
        const PurchaseCancelled(),
      );
    });

    test('no connection is a network failure', () {
      expect(
        failureFromStore(error(PurchasesErrorCode.networkError)),
        const NetworkFailure(),
      );
    });

    test('anything else keeps the store code for the test app', () {
      expect(
        failureFromStore(error(PurchasesErrorCode.storeProblemError)),
        UnknownFailure('store-${PurchasesErrorCode.storeProblemError.name}'),
      );
    });
  });

  group('which store key', () {
    test(
      'Android and iOS use their own RevenueCat key; none means no store',
      () {
        String? key(TargetPlatform p, {bool web = false}) => revenueCatKeyFor(
          p,
          isWeb: web,
          android: 'goog_key',
          ios: 'appl_key',
        );
        expect(key(TargetPlatform.android), 'goog_key');
        expect(key(TargetPlatform.iOS), 'appl_key');
        expect(key(TargetPlatform.android, web: true), isNull);
        expect(key(TargetPlatform.windows), isNull);
        expect(
          revenueCatKeyFor(
            TargetPlatform.android,
            isWeb: false,
            android: '',
            ios: 'appl_key',
          ),
          isNull,
        );
      },
    );
  });
}
