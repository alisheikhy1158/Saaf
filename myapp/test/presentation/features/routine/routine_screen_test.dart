// Covers: Figma 08 Routine (node 3:185), design.md §9 (empty / error states),
// A11Y-1/2/3/5/6/8, store-compliance (prices are a guide)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/data/services/web/fake_ai_coach_service.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/product_picks.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/presentation/features/routine/screens/routine_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

import '../../../helpers/pump_app.dart';

class _Catalog implements ProductCatalog {
  const _Catalog(this.products);
  final List<Product> products;

  @override
  Future<List<Product>> all() async => products;
}

/// The Figma example: oily, dark spots + breakouts, Rs 6,000 a month.
const _figma = SkinProfile(
  skinType: SkinType.oily,
  concerns: {SkinConcern.darkSpots, SkinConcern.acne},
  budget: BudgetBand.balanced,
);

List<Override> _with({
  SkinProfile profile = _figma,
  ProductCatalog catalog = const SeedProductCatalog(),
  CompletedScan? scan,
}) => [
  skinProfileControllerProvider.overrideWithBuild((ref, n) => profile),
  productCatalogProvider.overrideWithValue(catalog),
  completedScanProvider.overrideWithBuild((ref, n) => scan),
];

final _scan = CompletedScan(
  id: 'scan-1',
  takenAt: DateTime(2026, 10, 16),
  photos: const [],
);

Future<void> _open(
  WidgetTester tester, {
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const RoutineScreen(),
    scaffold: false,
    size: size,
    overrides: overrides ?? _with(),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('morning (as in Figma)', () {
    testWidgets('title and subtitle', (tester) async {
      await _open(tester);
      expect(find.text('Your routine'), findsOneWidget);
      expect(
        find.text('For dark spots & breakouts · Budget Rs 6,000/month'),
        findsOneWidget,
      );
    });

    testWidgets('lists the four steps with their prices', (tester) async {
      await _open(tester);
      for (final (name, caption, price) in [
        ('Neem Face Wash', 'Step 1 · Cleanser', 'Rs 650'),
        ('Niacinamide Serum', 'Step 2 · Treatment', 'Rs 1,450'),
        ('Oil-free Gel Moisturiser', 'Step 3 · Moisturiser', 'Rs 1,100'),
        ('Matte SPF 50 Sunscreen', 'Step 4 · Sun protection', 'Rs 1,850'),
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
        expect(find.text(caption), findsOneWidget, reason: caption);
        expect(find.text(price), findsOneWidget, reason: price);
      }
    });

    testWidgets('shows the step count, time and total', (tester) async {
      await _open(tester);
      expect(find.text('4 steps · about 5 min'), findsOneWidget);
      expect(find.text('Rs 5,050 total'), findsOneWidget);
    });

    testWidgets('has the Morning and Night tabs, Morning selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Night'), findsOneWidget);
      expect(find.bySemanticsLabel('Morning'), findsOneWidget);
      expect(find.bySemanticsLabel('Night'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('explains the results and that prices are a guide', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Results in 6–8 weeks'), findsOneWidget);
      expect(
        find.text('Prices are a guide and may differ in shops.'),
        findsOneWidget,
      );
    });

    testWidgets('names the next progress photo a month after the scan', (
      tester,
    ) async {
      await _open(tester, overrides: _with(scan: _scan));
      expect(
        find.text('Use it every day. Your next progress photo is on 15 Nov.'),
        findsOneWidget,
      );
    });

    testWidgets('without a scan the info card does not invent a date', (
      tester,
    ) async {
      await _open(tester);
      expect(
        find.text('Use it every day and check your progress every two weeks.'),
        findsOneWidget,
      );
    });
  });

  group('night', () {
    testWidgets('shows three steps and no sunscreen', (tester) async {
      await _open(tester);
      await tester.tap(find.text('Night'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('3 steps · about 4 min'), findsOneWidget);
      expect(find.text('Matte SPF 50 Sunscreen'), findsNothing);
      expect(find.text('Neem Face Wash'), findsOneWidget);
      expect(find.text('Step 1 · Cleanser'), findsOneWidget);
    });

    testWidgets('the total follows the tab', (tester) async {
      await _open(tester);
      await tester.tap(find.text('Night'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Rs 5,050 total'), findsNothing);
      expect(find.textContaining(' total'), findsOneWidget);
    });

    testWidgets('can go back to the morning', (tester) async {
      await _open(tester);
      await tester.tap(find.text('Night'), warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('Morning'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('4 steps · about 5 min'), findsOneWidget);
    });
  });

  group('subtitle variants', () {
    testWidgets('no concern and no budget answer', (tester) async {
      await _open(tester, overrides: _with(profile: const SkinProfile()));
      expect(find.text('For everyday skin health'), findsOneWidget);
    });

    testWidgets('one concern', (tester) async {
      await _open(
        tester,
        overrides: _with(
          profile: const SkinProfile(
            concerns: {SkinConcern.dryness},
            budget: BudgetBand.essential,
          ),
        ),
      );
      expect(find.text('For dryness · Budget Rs 3,000/month'), findsOneWidget);
    });

    testWidgets('the highest budget band has no limit', (tester) async {
      await _open(
        tester,
        overrides: _with(
          profile: const SkinProfile(
            concerns: {SkinConcern.acne},
            budget: BudgetBand.premium,
          ),
        ),
      );
      expect(find.text('For breakouts · No budget limit'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('too dear for the budget: says so, still shows the routine', (
      tester,
    ) async {
      const dear = _Catalog([
        Product(
          id: 'c',
          name: 'Costly Cleanser',
          category: ProductCategory.cleanser,
          pricePkr: 5000,
          times: {RoutineTime.morning, RoutineTime.night},
        ),
      ]);
      await _open(
        tester,
        overrides: _with(
          profile: const SkinProfile(budget: BudgetBand.essential),
          catalog: dear,
        ),
      );
      expect(find.text('Costly Cleanser'), findsOneWidget);
      expect(
        find.text('This is a little over your monthly budget.'),
        findsOneWidget,
      );
    });

    testWidgets('within budget: no over-budget message', (tester) async {
      await _open(tester);
      expect(find.textContaining('over your monthly budget'), findsNothing);
    });

    testWidgets('no products: empty state with a way to the quiz', (
      tester,
    ) async {
      await _open(tester, overrides: _with(catalog: const _Catalog([])));
      expect(find.text('We couldn’t build a routine yet'), findsOneWidget);
      expect(find.text('Take the skin quiz'), findsOneWidget);
      expect(find.text('Start my routine'), findsNothing);
    });

    testWidgets('a catalogue that fails can be retried', (tester) async {
      await pumpSaaf(
        tester,
        const RoutineScreen(),
        scaffold: false,
        overrides: [
          skinProfileControllerProvider.overrideWithBuild((ref, n) => _figma),
          productCatalogProvider.overrideWithValue(_FailingCatalog()),
          completedScanProvider.overrideWithBuild((ref, n) => null),
        ],
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('We couldn’t load your routine'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('Start my routine opens Home', (tester) async {
      await pumpSaafApp(tester, location: '/routine', overrides: _with());
      await tester.pump();
      await tester.ensureVisible(find.text('Start my routine'));
      await tester.tap(find.text('Start my routine'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });

    testWidgets('the bell opens the profile (reminders live there)', (
      tester,
    ) async {
      await pumpSaafApp(tester, location: '/routine', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Reminders'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-profile')), findsOneWidget);
    });

    testWidgets('back goes to the results, or Home when opened directly', (
      tester,
    ) async {
      await pumpSaafApp(tester, location: '/routine', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });

    testWidgets('the quiz button on the empty state opens the quiz', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location: '/routine',
        overrides: _with(catalog: const _Catalog([])),
      );
      await tester.pump();
      await tester.tap(find.text('Take the skin quiz'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-skinQuiz')), findsOneWidget);
    });
  });

  group('Saaf AI picks', () {
    late _PickService service;
    late InMemorySettingsRepository consentedSettings;
    setUp(() {
      service = _PickService();
      consentedSettings = InMemorySettingsRepository()
        ..write(
          AiConsent.settingName,
          DateTime(2026, 10, 17).toIso8601String(),
        );
    });

    List<Override> withAi({bool consented = true}) {
      final settings = consented
          ? consentedSettings
          : InMemorySettingsRepository();
      return [
        ..._with(),
        settingsRepositoryProvider.overrideWithValue(settings),
        aiProductServiceProvider.overrideWithValue(service),
        aiCoachServiceProvider.overrideWithValue(const FakeAiCoachService()),
        skinAnalysisProvider.overrideWith((ref) async => null),
      ];
    }

    Future<void> openAi(WidgetTester tester, {bool consented = true}) async {
      await _open(tester, overrides: withAi(consented: consented));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('without Saaf AI: offers it, and uses our standard picks', (
      tester,
    ) async {
      await openAi(tester, consented: false);
      expect(find.text('Let Saaf AI choose your products'), findsOneWidget);
      expect(find.text('Turn on Saaf AI'), findsOneWidget);
      expect(find.text('Neem Face Wash'), findsOneWidget);
      expect(service.calls, 0);
    });

    testWidgets('with Saaf AI: its choice is in the routine, with the reason', (
      tester,
    ) async {
      await openAi(tester);
      expect(service.calls, 1);
      expect(find.text('Picked by Saaf AI'), findsOneWidget);
      expect(find.text('Chosen for oily skin with breakouts.'), findsOneWidget);
      // The AI chose the gentle cleanser over the neem wash.
      expect(find.text('Gel Cleanser'), findsOneWidget);
      expect(find.text('Neem Face Wash'), findsNothing);

      await tester.ensureVisible(find.text('Why these products'));
      await tester.tap(find.text('Why these products'));
      await tester.pump();
      expect(find.textContaining('Kind to oily skin.'), findsOneWidget);
    });

    testWidgets('a picks answer can be reported', (tester) async {
      await openAi(tester);
      await tester.ensureVisible(find.byTooltip('Report this answer'));
      await tester.tap(find.byTooltip('Report this answer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wrong or misleading'));
      await tester.pumpAndSettle();
      expect(find.text('Reported'), findsOneWidget);
    });

    testWidgets('when Saaf AI fails, our picks stay and it can be retried', (
      tester,
    ) async {
      service.fail = true;
      await openAi(tester);
      expect(find.text('Neem Face Wash'), findsOneWidget);
      expect(
        find.text('Saaf AI couldn’t choose right now, so these are our picks.'),
        findsOneWidget,
      );
      service.fail = false;
      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Gel Cleanser'), findsOneWidget);
    });

    testWidgets('the same answers are not sent twice', (tester) async {
      await openAi(tester);
      await openAi(tester);
      expect(service.calls, 1);
    });

    testWidgets('is robust at every size, 200 % text and in Urdu', (
      tester,
    ) async {
      await expectRobustLayoutSettled(
        tester,
        () => const RoutineScreen(),
        scaffold: false,
        overrides: withAi(),
      );
    });
  });

  group('layout', () {
    testWidgets('morning and night are robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const RoutineScreen(),
        scaffold: false,
        overrides: _with(scan: _scan),
      );
      await expectRobustLayoutSettled(
        tester,
        () => const RoutineScreen(),
        scaffold: false,
        overrides: _with(),
        after: () async {
          await tester.ensureVisible(find.byIcon(Icons.nightlight_outlined));
          await tester.tap(
            find.byIcon(Icons.nightlight_outlined),
            warnIfMissed: false,
          );
          await tester.pump();
        },
      );
      // Start from a fresh screen, not the one scrolled to the night tab.
      await tester.pumpWidget(const SizedBox());
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('empty state is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const RoutineScreen(),
        scaffold: false,
        overrides: _with(catalog: const _Catalog([])),
      );
      await _open(tester, overrides: _with(catalog: const _Catalog([])));
      await expectTapTargetsAccessible(tester);
    });
  });
}

class _FailingCatalog implements ProductCatalog {
  @override
  Future<List<Product>> all() async => throw StateError('offline');
}

/// Saaf AI choosing the gel cleanser (instead of the neem wash) for the Figma
/// profile; [fail] makes it unavailable.
class _PickService implements AiProductService {
  int calls = 0;
  bool fail = false;

  @override
  Future<Result<ProductPicks>> pickProducts({
    required AiContext context,
    required List<Product> candidates,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    calls++;
    if (fail) return const Err(ServiceUnavailable());
    return const Ok(
      ProductPicks(
        summary: 'Chosen for oily skin with breakouts.',
        picks: [
          ProductPick(productId: 'cleanser-gel', reason: 'Kind to oily skin.'),
        ],
      ),
    );
  }

  @override
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  }) async => const Ok(ProductInsight.notFound());
}
