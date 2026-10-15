// Covers: design.md §6 SaafBottomNav / SaafAdaptiveNav, §7 (bottom pill on
// compact, NavigationRail on medium/expanded, labels on expanded), A11Y-1,
// A11Y-5, A11Y-8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_adaptive_nav.dart';

import '../../../helpers/pump_app.dart';

const _destinations = [
  SaafNavDestination(icon: Icons.home_outlined, label: 'Home'),
  SaafNavDestination(icon: Icons.photo_camera_outlined, label: 'Scan'),
  SaafNavDestination(icon: Icons.show_chart, label: 'Progress'),
  SaafNavDestination(icon: Icons.person_outline, label: 'Profile'),
];

Widget nav({int selected = 0, ValueChanged<int>? onSelected}) =>
    SaafAdaptiveNav(
      destinations: _destinations,
      selectedIndex: selected,
      onSelected: onSelected ?? (_) {},
      child: const SizedBox.expand(key: ValueKey('content')),
    );

void main() {
  group('compact (< 600 dp)', () {
    testWidgets('shows a 64 dp floating ink pill, no rail', (tester) async {
      await pumpSaaf(tester, nav());
      expect(find.byKey(const ValueKey('saaf-bottom-nav')), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      final pill = tester.getRect(
        find.byKey(const ValueKey('saaf-bottom-nav')),
      );
      expect(pill.height, 64);
      expect(pill.left, 20, reason: 'full width minus the gutters');
      expect(pill.right, 390 - 20);
    });

    testWidgets('works with no Material/Scaffold above it (wraps a screen)', (
      tester,
    ) async {
      await pumpSaaf(tester, nav(), scaffold: false);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Scan'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints the theme background behind the pill', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpSaaf(tester, nav(), scaffold: false, themeMode: mode);
        final context = tester.element(find.byKey(const ValueKey('content')));
        final background = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('saaf-nav-background')),
        );
        expect(
          background.color,
          Theme.of(context).colorScheme.surface,
          reason: '$mode',
        );
      }
    });

    testWidgets('does not cover the content', (tester) async {
      await pumpSaaf(tester, nav());
      final pill = tester.getRect(
        find.byKey(const ValueKey('saaf-bottom-nav')),
      );
      final content = tester.getRect(find.byKey(const ValueKey('content')));
      expect(content.bottom, lessThanOrEqualTo(pill.top));
    });

    testWidgets('marks only the selected destination with a dot', (
      tester,
    ) async {
      await pumpSaaf(tester, nav(selected: 2));
      expect(find.byKey(const ValueKey('nav-dot')), findsOneWidget);
    });

    testWidgets('reports the tapped destination', (tester) async {
      int? tapped;
      await pumpSaaf(tester, nav(onSelected: (i) => tapped = i));
      await tester.tap(find.byTooltip('Progress'));
      expect(tapped, 2);
    });

    testWidgets('labels every destination and marks the selected one', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSaaf(tester, nav(selected: 1));
      for (final d in _destinations) {
        expect(find.bySemanticsLabel(d.label), findsOneWidget, reason: d.label);
      }
      expect(
        tester.getSemantics(find.bySemanticsLabel('Scan')),
        isSemantics(
          label: 'Scan',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('has 48 dp hit areas', (tester) async {
      await pumpSaaf(tester, nav());
      await expectTapTargetsAccessible(tester);
    });
  });

  group('medium (600–839 dp)', () {
    testWidgets('uses a NavigationRail without labels', (tester) async {
      await pumpSaaf(tester, nav(), size: const Size(768, 1024));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byKey(const ValueKey('saaf-bottom-nav')), findsNothing);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).labelType,
        NavigationRailLabelType.none,
      );
    });

    testWidgets('reports the tapped destination', (tester) async {
      int? tapped;
      await pumpSaaf(
        tester,
        nav(onSelected: (i) => tapped = i),
        size: const Size(768, 1024),
      );
      await tester.tap(find.byIcon(Icons.person_outline));
      expect(tapped, 3);
    });
  });

  group('expanded (≥ 840 dp)', () {
    testWidgets('uses a NavigationRail with labels', (tester) async {
      await pumpSaaf(tester, nav(), size: const Size(1280, 800));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).labelType,
        NavigationRailLabelType.all,
      );
      expect(find.text('Home'), findsOneWidget);
    });
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, nav);
  });
}
