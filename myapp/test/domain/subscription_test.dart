// Covers: 13 Saaf Pro paywall — plans, savings, purchase / restore, entitlement
// (store-compliance §4: store prices, restore, cancel = PurchaseCancelled)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/fake_subscription_repository.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/usecases/purchase_plan.dart';

const _yearly = SubscriptionPlan(
  id: 'yearly',
  period: PlanPeriod.yearly,
  priceText: 'Rs 3,999',
  pricePerMonthText: 'Rs 333',
  priceValue: 3999,
  trialDays: 7,
);
const _monthly = SubscriptionPlan(
  id: 'monthly',
  period: PlanPeriod.monthly,
  priceText: 'Rs 599',
  priceValue: 599,
);

void main() {
  group('savings', () {
    test('the Figma plans save 44 %', () {
      expect(savePercent(yearly: _yearly, monthly: _monthly), 44);
    });

    test('no saving when the yearly plan is not cheaper', () {
      const dear = SubscriptionPlan(
        id: 'y',
        period: PlanPeriod.yearly,
        priceText: 'x',
        priceValue: 8000,
      );
      expect(savePercent(yearly: dear, monthly: _monthly), isNull);
    });

    test('no saving can be worked out without prices', () {
      const free = SubscriptionPlan(
        id: 'm',
        period: PlanPeriod.monthly,
        priceText: 'x',
        priceValue: 0,
      );
      expect(savePercent(yearly: _yearly, monthly: free), isNull);
    });

    test('a plan with a trial says so', () {
      expect(_yearly.hasTrial, isTrue);
      expect(_monthly.hasTrial, isFalse);
    });
  });

  group('FakeSubscriptionRepository', () {
    test('offers a yearly and a monthly plan', () async {
      final plans = (await FakeSubscriptionRepository().plans()).valueOrNull!;
      expect(plans.map((p) => p.period), [
        PlanPeriod.yearly,
        PlanPeriod.monthly,
      ]);
      expect(plans.first.trialDays, 7);
      expect(plans.first.priceText, 'Rs 3,999');
    });

    test('starts free and becomes Pro after a purchase', () async {
      final repository = FakeSubscriptionRepository();
      expect(await repository.isPro(), isFalse);
      final changes = repository.proChanges.take(1).toList();
      final plans = (await repository.plans()).valueOrNull!;
      expect((await repository.purchase(plans.first)).isOk, isTrue);
      expect(await repository.isPro(), isTrue);
      expect(await changes, [true]);
    });

    test(
      'cancelling the store sheet is PurchaseCancelled and changes nothing',
      () async {
        final repository = FakeSubscriptionRepository(
          outcome: PurchaseOutcome.cancel,
        );
        final plans = (await repository.plans()).valueOrNull!;
        expect(
          (await repository.purchase(plans.first)).failureOrNull,
          const PurchaseCancelled(),
        );
        expect(await repository.isPro(), isFalse);
      },
    );

    test('a store failure is a failure and changes nothing', () async {
      final repository = FakeSubscriptionRepository(
        outcome: PurchaseOutcome.fail,
      );
      final plans = (await repository.plans()).valueOrNull!;
      expect(
        (await repository.purchase(plans.first)).failureOrNull,
        isA<NetworkFailure>(),
      );
      expect(await repository.isPro(), isFalse);
    });

    test('restore finds an earlier purchase, or nothing', () async {
      final repository = FakeSubscriptionRepository();
      expect((await repository.restore()).valueOrNull, isFalse);
      final plans = (await repository.plans()).valueOrNull!;
      await repository.purchase(plans.first);
      expect((await repository.restore()).valueOrNull, isTrue);
    });
  });

  group('use cases', () {
    test('PurchasePlan passes the result through', () async {
      final repository = FakeSubscriptionRepository();
      final plans = (await repository.plans()).valueOrNull!;
      expect((await PurchasePlan(repository)(plans.first)).isOk, isTrue);
    });

    test('an exception becomes an UnknownFailure', () async {
      final result = await PurchasePlan(_Throwing())(_yearly);
      expect(result.failureOrNull, const UnknownFailure('purchase'));
    });

    test(
      'RestorePurchases passes the result through, and catches exceptions',
      () async {
        expect(
          (await RestorePurchases(FakeSubscriptionRepository())()).valueOrNull,
          isFalse,
        );
        expect(
          (await RestorePurchases(_Throwing())()).failureOrNull,
          const UnknownFailure('restore'),
        );
      },
    );
  });
}

class _Throwing extends FakeSubscriptionRepository {
  @override
  Future<Result<void>> purchase(SubscriptionPlan plan) async =>
      throw StateError('x');

  @override
  Future<Result<bool>> restore() async => throw StateError('x');
}
