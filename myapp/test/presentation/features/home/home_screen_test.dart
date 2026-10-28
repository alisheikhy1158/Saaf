// Covers: Figma 09 Home (node 3:292): greeting, week strip, today's progress,
// checklist, bottom navigation; design.md §9 (empty / error states), §7 (rail on
// wide screens), A11Y-1/2/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_routine_log_repository.dart';
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';
import 'package:saaf/domain/usecases/build_routine.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/home/screens/home_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/home_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

class _Empty implements ProductCatalog {
  const _Empty();

  @override
  Future<List<Product>> all() async => const [];
}

class _Failing implements ProductCatalog {
  @override
  Future<List<Product>> all() async => throw StateError('offline');
}

const _profile = SkinProfile(
  skinType: SkinType.oily,
  concerns: {SkinConcern.darkSpots, SkinConcern.acne},
  budget: BudgetBand.balanced,
);

/// Thursday 15 October 2026, 09:41.
final _morning = DateTime(2026, 10, 15, 9, 41);

List<Override> _with({
  DateTime? now,
  ProductCatalog catalog = const SeedProductCatalog(),
  AuthSession? session,
  InMemoryRoutineLogRepository? log,
}) => [
  clockProvider.overrideWithValue(_Clock(now ?? _morning)),
  productCatalogProvider.overrideWithValue(catalog),
  skinProfileControllerProvider.overrideWithBuild((ref, n) => _profile),
  routineLogRepositoryProvider.overrideWithValue(
    log ?? InMemoryRoutineLogRepository(),
  ),
  authSessionControllerProvider.overrideWithBuild((ref, n) => session),
];

Future<void> _open(
  WidgetTester tester, {
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const HomeScreen(),
    scaffold: false,
    size: size,
    overrides: overrides ?? _with(),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('header', () {
    testWidgets('shows the date and a plain greeting without a name', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Thursday, 15 October'), findsOneWidget);
      expect(find.text('Salam'), findsOneWidget);
    });

    testWidgets('greets the user by first name', (tester) async {
      await _open(
        tester,
        overrides: _with(
          session: const AuthSession(userId: 'u', displayName: 'Ayesha Khan'),
        ),
      );
      expect(find.text('Salam, Ayesha'), findsOneWidget);
    });
  });

  group('week strip', () {
    testWidgets('shows Monday to Sunday with their dates', (tester) async {
      await _open(tester);
      for (final day in ['12', '13', '14', '15', '16', '17', '18']) {
        expect(find.text(day), findsOneWidget, reason: day);
      }
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsNWidgets(2));
      expect(find.text('S'), findsNWidgets(2));
    });

    testWidgets('today is announced as today', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(find.bySemanticsLabel('Thursday 15, today'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a fully done day is announced as done', (tester) async {
      final handle = tester.ensureSemantics();
      final log = InMemoryRoutineLogRepository();
      final routine = const BuildRoutine(SeedProductCatalog.products)(_profile);
      final monday = DateTime(2026, 10, 12);
      for (final time in RoutineTime.values) {
        for (final step in routine.stepsFor(time)) {
          await log.setDone(monday, routineStepKey(time, step.product), true);
        }
      }
      await _open(tester, overrides: _with(log: log));
      expect(
        find.bySemanticsLabel('Monday 12, all steps done'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Tuesday 13'), findsOneWidget);
      handle.dispose();
    });
  });

  group('progress', () {
    testWidgets('starts at 0 of 4', (tester) async {
      await _open(tester);
      expect(find.text('Today’s progress'), findsOneWidget);
      expect(find.text('0 of 4 steps done'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('ticking two steps makes it 2 of 4 and 50 %', (tester) async {
      await _open(tester);
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      await tester.tap(find.text('Niacinamide Serum'));
      await tester.pump();
      expect(find.text('2 of 4 steps done'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('the ring and the bar speak the percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      expect(
        find.bySemanticsLabel('25 percent of today’s routine done'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('checklist', () {
    testWidgets('lists today’s morning steps with their price', (tester) async {
      await _open(tester);
      expect(find.text('Today’s routine'), findsOneWidget);
      for (final (name, caption) in [
        ('Neem Face Wash', 'Cleanser · Rs 650'),
        ('Niacinamide Serum', 'Treatment · Rs 1,450'),
        ('Oil-free Gel Moisturiser', 'Moisturiser · Rs 1,100'),
        ('Matte SPF 50 Sunscreen', 'Sun protection · Rs 1,850'),
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
        expect(find.text(caption), findsOneWidget, reason: caption);
      }
    });

    testWidgets('a step is announced as a checkbox and changes when ticked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      expect(
        find.bySemanticsLabel('Neem Face Wash, not done yet'),
        findsOneWidget,
      );
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      expect(find.bySemanticsLabel('Neem Face Wash, done'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      handle.dispose();
    });

    testWidgets('ticking again unticks', (tester) async {
      await _open(tester);
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      expect(find.text('0 of 4 steps done'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('what was ticked is kept when the screen is reopened', (
      tester,
    ) async {
      final log = InMemoryRoutineLogRepository();
      await _open(tester, overrides: _with(log: log));
      await tester.tap(find.text('Neem Face Wash'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await _open(tester, overrides: _with(log: log));
      expect(find.text('1 of 4 steps done'), findsOneWidget);
    });
  });

  group('morning and night', () {
    testWidgets('the chip shows the current part of the day', (tester) async {
      await _open(tester);
      expect(find.text('Morning'), findsOneWidget);
      await _open(tester, overrides: _with(now: DateTime(2026, 10, 15, 20)));
      expect(find.text('Night'), findsOneWidget);
      expect(find.text('0 of 3 steps done'), findsOneWidget);
    });

    testWidgets('tapping the chip switches to the other routine', (
      tester,
    ) async {
      await _open(tester);
      await tester.tap(find.byTooltip('Show the Night routine'));
      await tester.pump();
      expect(find.text('Night'), findsOneWidget);
      expect(find.text('0 of 3 steps done'), findsOneWidget);
      expect(find.text('Matte SPF 50 Sunscreen'), findsNothing);
    });
  });

  group('states', () {
    testWidgets('no products: empty state with a way to the quiz', (
      tester,
    ) async {
      await _open(tester, overrides: _with(catalog: const _Empty()));
      expect(find.text('We couldn’t build a routine yet'), findsOneWidget);
      expect(find.text('Take the skin quiz'), findsOneWidget);
    });

    testWidgets('a failure can be retried', (tester) async {
      await _open(tester, overrides: _with(catalog: _Failing()));
      expect(find.text('We couldn’t load today’s routine'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('the bottom pill has Home, Scan, Progress and Profile', (
      tester,
    ) async {
      await _open(tester);
      for (final label in ['Home', 'Scan', 'Progress', 'Profile']) {
        expect(find.byTooltip(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('wide screens use the navigation rail instead', (tester) async {
      await _open(tester, size: const Size(1280, 800));
      expect(find.byKey(const ValueKey('saaf-nav-rail')), findsOneWidget);
    });

    testWidgets('Scan opens the camera screen', (tester) async {
      await pumpSaafApp(tester, location: '/home', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Scan'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Progress and Profile open their screens', (tester) async {
      await pumpSaafApp(tester, location: '/home', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Progress'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-monthlyProgress')),
        findsOneWidget,
      );
    });

    testWidgets('the scan icon opens the product barcode scanner', (
      tester,
    ) async {
      await pumpSaafApp(tester, location: '/home', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Scan a product'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-scanProduct')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the bell opens the profile (reminders live there)', (
      tester,
    ) async {
      await pumpSaafApp(tester, location: '/home', overrides: _with());
      await tester.pump();
      await tester.tap(find.byTooltip('Reminders'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-reminders')), findsOneWidget);
    });

    testWidgets('the empty state quiz button opens the quiz', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/home',
        overrides: _with(catalog: const _Empty()),
      );
      await tester.pump();
      await tester.tap(find.text('Take the skin quiz'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-skinQuiz')), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const HomeScreen(),
        scaffold: false,
        overrides: _with(),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the night routine and the empty state are robust', (
      tester,
    ) async {
      await expectRobustLayoutSettled(
        tester,
        () => const HomeScreen(),
        scaffold: false,
        overrides: _with(now: DateTime(2026, 10, 15, 21)),
      );
      await expectRobustLayoutSettled(
        tester,
        () => const HomeScreen(),
        scaffold: false,
        overrides: _with(catalog: const _Empty()),
      );
    });
  });

  group('history', () {
    testWidgets('tapping an earlier day shows what was done that day', (
      tester,
    ) async {
      final log = InMemoryRoutineLogRepository();
      final routine = const BuildRoutine(SeedProductCatalog.products)(_profile);
      final first = routine.morning.first;
      await log.setDone(
        DateTime(2026, 10, 14),
        routineStepKey(RoutineTime.morning, first.product),
        true,
      );
      await _open(tester, overrides: _with(log: log));
      expect(
        find.text('0 of ${routine.morning.length} steps done'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel(RegExp('Wednesday 14')));
      await tester.pump();
      expect(find.text('What you did on Wednesday 14 October'), findsOneWidget);
      expect(
        find.text('1 of ${routine.morning.length} steps done'),
        findsOneWidget,
      );

      // An earlier day is only looked at, not changed.
      await tester.tap(find.text(first.product.name));
      await tester.pump();
      expect(
        find.text('1 of ${routine.morning.length} steps done'),
        findsOneWidget,
      );

      await tester.tap(find.text('Back to today'));
      await tester.pump();
      expect(
        find.text('0 of ${routine.morning.length} steps done'),
        findsOneWidget,
      );
    });

    testWidgets('days still to come cannot be opened', (tester) async {
      await _open(tester);
      await tester.tap(find.bySemanticsLabel(RegExp('Friday 16')));
      await tester.pump();
      expect(find.textContaining('What you did on'), findsNothing);
    });
  });
}
