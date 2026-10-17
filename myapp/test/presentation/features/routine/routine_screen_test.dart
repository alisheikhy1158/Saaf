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
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/ingredient.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/active_rules.dart';
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
import 'package:saaf/presentation/providers/product_providers.dart';
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
    late _PlanService service;
    late InMemorySettingsRepository consentedSettings;
    setUp(() {
      service = _PlanService();
      consentedSettings = InMemorySettingsRepository()
        ..write(AiConsent.settingName, DateTime(2026, 10, 17).toIso8601String())
        ..write(SettingNames.currentProducts, '["Nivea Soft","Night Serum"]');
    });

    List<Override> withAi({
      bool consented = true,
      SkinProfile profile = _figma,
    }) {
      final settings = consented
          ? consentedSettings
          : InMemorySettingsRepository();
      return [
        ..._with(profile: profile),
        settingsRepositoryProvider.overrideWithValue(settings),
        aiProductServiceProvider.overrideWithValue(service),
        aiCoachServiceProvider.overrideWithValue(const FakeAiCoachService()),
        skinAnalysisProvider.overrideWith((ref) async => null),
      ];
    }

    Future<void> openAi(
      WidgetTester tester, {
      bool consented = true,
      SkinProfile profile = _figma,
    }) async {
      await _open(
        tester,
        overrides: withAi(consented: consented, profile: profile),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.tap(find.text(text));
      await tester.pump();
    }

    testWidgets('the user’s own products are in the routine, marked Yours', (
      tester,
    ) async {
      final settings = InMemorySettingsRepository();
      await settings.write(
        SettingNames.currentProducts,
        '[{"name":"My Face Wash","step":"cleanser"},{"name":"Lip balm","step":"other"}]',
      );
      await _open(
        tester,
        overrides: [
          ..._with(),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
      );
      await tester.pump();
      expect(find.text('My Face Wash'), findsOneWidget);
      expect(find.text('Yours'), findsOneWidget);
      expect(find.text('Neem Face Wash'), findsNothing);
      expect(find.text('Lip balm'), findsNothing);
    });

    testWidgets('without Saaf AI: offers it, and uses our standard picks', (
      tester,
    ) async {
      await openAi(tester, consented: false);
      expect(find.text('Let Saaf AI choose your products'), findsOneWidget);
      expect(find.textContaining('r/PakistaniSkincare'), findsOneWidget);
      expect(find.text('Turn on Saaf AI'), findsOneWidget);
      expect(find.text('Neem Face Wash'), findsOneWidget);
      expect(service.calls, 0);
    });

    testWidgets('sends the products the user uses now', (tester) async {
      await openAi(tester);
      expect(service.current?.map((p) => p.name), [
        'Nivea Soft',
        'Night Serum',
      ]);
    });

    testWidgets('a product it found on the web is in the routine', (
      tester,
    ) async {
      await openAi(tester);
      expect(service.calls, 1);
      expect(find.text('Picked by Saaf AI'), findsOneWidget);
      expect(find.text('Chosen for oily skin with breakouts.'), findsOneWidget);
      expect(find.text('CeraVe Foaming Facial Cleanser'), findsOneWidget);
      expect(find.text('Neem Face Wash'), findsNothing);
    });

    testWidgets('why, what people say and the sources', (tester) async {
      final links = FakeExternalLinkService();
      await _open(
        tester,
        overrides: [
          ...withAi(),
          externalLinkServiceProvider.overrideWithValue(links),
        ],
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tapText(tester, 'Why these products');
      expect(find.text('Gentle and liked for oily skin.'), findsOneWidget);
      expect(
        find.text('What people say: Popular on r/PakistaniSkincare.'),
        findsOneWidget,
      );
      await tapText(tester, 'reddit.com');
      expect(links.opened, [
        'https://www.reddit.com/r/PakistaniSkincare/comments/abc',
      ]);
      // No AI price in the routine: a link to check it instead.
      await tester.ensureVisible(find.text('Check prices online').first);
      await tester.tap(find.text('Check prices online').first);
      await tester.pump();
      expect(
        links.opened.last,
        'https://www.google.com/search?q=CeraVe+Foaming+Facial+Cleanser+price+in+Pakistan',
      );
    });

    testWidgets('keep / replace / stop for the products the user uses', (
      tester,
    ) async {
      await openAi(tester);
      expect(find.text('Products you use now'), findsOneWidget);
      expect(find.text('Replace'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
      expect(
        find.text('Use instead: CeraVe Foaming Facial Cleanser'),
        findsOneWidget,
      );
      expect(
        find.text('What people say: Some find it greasy.'),
        findsOneWidget,
      );
      // No safety answers: no warning.
      expect(find.textContaining('From your answers'), findsNothing);
    });

    testWidgets('the phone adds a warning Saaf AI could not give', (
      tester,
    ) async {
      await openAi(
        tester,
        profile: _figma.copyWith(
          safetyFlags: {SafetyFlag.pregnantOrBreastfeeding},
        ),
      );
      expect(
        find.text(
          'From your answers: ask a doctor before using this while pregnant or breastfeeding.',
        ),
        findsOneWidget,
      );
      // And its retinol pick never reaches the routine.
      await tapText(tester, 'Night');
      expect(find.text('Retinol Night Serum 0.3%'), findsNothing);
    });

    testWidgets('without pregnancy the retinol pick is used at night', (
      tester,
    ) async {
      await openAi(tester);
      await tapText(tester, 'Night');
      expect(find.text('Retinol Night Serum 0.3%'), findsOneWidget);
    });

    testWidgets('an answer can be reported', (tester) async {
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
      await tapText(tester, 'Try again');
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('CeraVe Foaming Facial Cleanser'), findsOneWidget);
    });

    testWidgets('the same answers are not sent twice', (tester) async {
      await openAi(tester);
      await tester.pumpWidget(const SizedBox());
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

/// Saaf AI with a plan from the web: a cleanser instead of the neem wash, a
/// retinol serum for the night, and verdicts on the user's two products;
/// [fail] makes it unavailable.
class _PlanService implements AiProductService {
  int calls = 0;
  bool fail = false;
  List<OwnedProduct>? current;

  @override
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<OwnedProduct> currentProducts,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    calls++;
    current = currentProducts;
    if (fail) return const Err(ServiceUnavailable());
    return Ok(
      AiRoutinePlan(
        summary: 'Chosen for oily skin with breakouts.',
        picks: [
          AiPick(
            product: ActiveRules.product(
              id: 'ai-cleanser-cerave',
              name: 'CeraVe Foaming Facial Cleanser',
              category: ProductCategory.cleanser,
              pricePkr: 600,
              times: const {RoutineTime.morning, RoutineTime.night},
              actives: const {Ingredient.niacinamide, Ingredient.ceramides},
              fragranceFree: true,
            ),
            brand: 'CeraVe',
            why: 'Gentle and liked for oily skin.',
            reviews: 'Popular on r/PakistaniSkincare.',
            sources: const [
              'https://www.reddit.com/r/PakistaniSkincare/comments/abc',
            ],
          ),
          AiPick(
            product: ActiveRules.product(
              id: 'ai-treatment-retinol',
              name: 'Retinol Night Serum 0.3%',
              category: ProductCategory.treatment,
              pricePkr: 900,
              times: const {RoutineTime.night},
              actives: const {Ingredient.retinol},
              fragranceFree: true,
            ),
            brand: 'Demo',
            why: 'For marks.',
          ),
        ],
        current: const [
          CurrentProductReview(
            name: 'Nivea Soft',
            verdict: ProductVerdict.replace,
            why: 'Heavy for oily skin.',
            reviews: 'Some find it greasy.',
            replaceWith: 'CeraVe Foaming Facial Cleanser',
          ),
          CurrentProductReview(
            name: 'Night Serum',
            verdict: ProductVerdict.keep,
            why: 'Helps marks.',
            actives: {Ingredient.retinol},
          ),
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
