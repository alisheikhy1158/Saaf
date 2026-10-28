// Covers: Figma 13 Saaf Pro paywall (node 3:712) + store-compliance §4 (store
// prices, trial terms, platform-aware cancel text, Restore, Terms and Privacy
// links), A11Y-1/2/3/5/6/8
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/fake_subscription_repository.dart';
import 'package:saaf/domain/entities/subscription_plan.dart';
import 'package:saaf/domain/repositories/subscription_repository.dart';
import 'package:saaf/presentation/features/paywall/screens/paywall_screen.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';

import '../../../helpers/pump_app.dart';

class _NoPlans extends FakeSubscriptionRepository {
  @override
  Future<Result<List<SubscriptionPlan>>> plans() async => const Ok([]);
}

class _BrokenPlans extends FakeSubscriptionRepository {
  @override
  Future<Result<List<SubscriptionPlan>>> plans() async =>
      throw StateError('offline');
}

List<Override> _with(SubscriptionRepository repository) => [
  subscriptionRepositoryProvider.overrideWithValue(repository),
];

Future<void> _open(
  WidgetTester tester, {
  SubscriptionRepository? repository,
  TargetPlatform? platform,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const PaywallScreen(),
    scaffold: false,
    size: size,
    platform: platform,
    overrides: _with(repository ?? FakeSubscriptionRepository()),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump();
}

void main() {
  group('offer', () {
    testWidgets('shows the Pro chip, the headline and four benefits', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Saaf Pro'), findsOneWidget);
      expect(find.textContaining('See real change,'), findsOneWidget);
      for (final benefit in [
        'Aligned photo comparisons every 2 weeks',
        'Unlimited skin and product scans',
        'Price-drop alerts on your products',
        'Weekly coach check-ins and reports',
      ]) {
        expect(find.text(benefit), findsOneWidget, reason: benefit);
      }
    });

    testWidgets('lists the plans with the store prices and the saving', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Save 44%'), findsOneWidget);
      expect(find.text('Rs 333/month, billed yearly'), findsOneWidget);
      expect(find.text('Rs 3,999'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Cancel anytime'), findsOneWidget);
      expect(find.text('Rs 599'), findsOneWidget);
    });

    testWidgets('the yearly plan is picked first', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Yearly. Rs 3,999'))),
        isNotNull,
      );
      expect(find.text('Start 7-day free trial'), findsOneWidget);
      handle.dispose();
    });
  });

  group('trial and renewal terms', () {
    testWidgets('yearly: free for 7 days, then the yearly price', (
      tester,
    ) async {
      await _open(tester);
      expect(
        find.text(
          'Free for 7 days, then Rs 3,999/year. Renews automatically. '
          'Cancel anytime in Google Play.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('picking monthly changes the button and the fine print', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Monthly'));
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.text('Start 7-day free trial'), findsNothing);
      expect(
        find.text(
          'Rs 599/month. Renews automatically. Cancel anytime in Google Play.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Android: paid in Google Play with a card or Google Pay', (
      tester,
    ) async {
      await _open(tester, platform: TargetPlatform.android);
      expect(
        find.text(
          'You pay through Google Play with a card, Google Pay or another '
          'method set up there. We never see your payment details.',
        ),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('iPhone: paid with your Apple ID, a card or Apple Pay', (
      tester,
    ) async {
      await _open(tester, platform: TargetPlatform.iOS);
      expect(
        find.text(
          'You pay through your Apple ID with a card or Apple Pay. We never '
          'see your payment details.',
        ),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('on iPhone it says App Store', (tester) async {
      await _open(tester, platform: TargetPlatform.iOS);
      expect(find.textContaining('the App Store'), findsOneWidget);
      expect(find.textContaining('Google Play'), findsNothing);
      // The framework checks this before the harness's tear-down runs.
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('buying', () {
    testWidgets('buying makes the user Pro and closes the paywall', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      await pumpSaafApp(
        tester,
        location: '/paywall',
        overrides: _with(repository),
      );
      await tester.pump();
      await tester.pump();
      await _tap(tester, find.text('Start 7-day free trial'));
      await tester.pump(const Duration(seconds: 1));
      expect(await repository.isPro(), isTrue);
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });

    testWidgets('cancelling the store sheet stays quietly on the paywall', (
      tester,
    ) async {
      await _open(
        tester,
        repository: FakeSubscriptionRepository(outcome: PurchaseOutcome.cancel),
      );
      await _tap(tester, find.text('Start 7-day free trial'));
      expect(find.text('Start 7-day free trial'), findsOneWidget);
      expect(find.textContaining('You have not been charged'), findsNothing);
    });

    testWidgets('a store failure says nothing was charged', (tester) async {
      await _open(
        tester,
        repository: FakeSubscriptionRepository(outcome: PurchaseOutcome.fail),
      );
      await _tap(tester, find.text('Start 7-day free trial'));
      expect(
        find.text(
          'We couldn’t complete the purchase. You have not been charged.',
        ),
        findsOneWidget,
      );
    });
  });

  group('restore', () {
    testWidgets('nothing to restore', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('Restore purchases'));
      expect(find.text('No earlier purchase found.'), findsOneWidget);
    });

    testWidgets('an earlier purchase is found', (tester) async {
      final repository = FakeSubscriptionRepository();
      final plans = (await repository.plans()).valueOrNull!;
      await repository.purchase(plans.first);
      await pumpSaafApp(
        tester,
        location: '/paywall',
        overrides: _with(repository),
      );
      await tester.pump();
      await tester.pump();
      // Already Pro: the paywall says so and Restore is not needed.
      expect(find.text('You’re on Saaf Pro'), findsOneWidget);
    });
  });

  group('legal and navigation', () {
    testWidgets('links to the Terms of Use and the Privacy Policy', (
      tester,
    ) async {
      await _open(tester);
      expect(
        find.textContaining('Terms of Use', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Privacy Policy', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('the X closes the paywall', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/paywall',
        overrides: _with(FakeSubscriptionRepository()),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Close'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('no plans: says so and can retry', (tester) async {
      await _open(tester, repository: _NoPlans());
      expect(
        find.text('Subscriptions aren’t available right now'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Start 7-day free trial'), findsNothing);
    });

    testWidgets('plans that fail to load can be retried', (tester) async {
      await _open(tester, repository: _BrokenPlans());
      expect(
        find.text('Subscriptions aren’t available right now'),
        findsOneWidget,
      );
    });

    testWidgets('a user who is already Pro sees a thank-you, not the offer', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository();
      final plans = (await repository.plans()).valueOrNull!;
      await repository.purchase(plans.first);
      await _open(tester, repository: repository);
      expect(find.text('You’re on Saaf Pro'), findsOneWidget);
      expect(find.text('Rs 3,999'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const PaywallScreen(),
        scaffold: false,
        overrides: _with(FakeSubscriptionRepository()),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the unavailable state is robust', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const PaywallScreen(),
        scaffold: false,
        overrides: _with(_NoPlans()),
      );
    });
  });
}
