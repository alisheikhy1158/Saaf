// Covers: SaafMainNav — Home, Scan, Progress, Profile (Figma "Bottom nav"),
// design.md §7 (rail on wide screens)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/widgets/common/saaf_main_nav.dart';

import '../../../helpers/pump_app.dart';

void main() {
  test(
    'the four tabs lead to Home, Scan, Progress and Profile, in that order',
    () {
      expect(SaafMainTab.values.map((t) => t.route), [
        SaafRoute.home,
        SaafRoute.selfieCapture,
        SaafRoute.monthlyProgress,
        SaafRoute.profile,
      ]);
    },
  );

  testWidgets('labels every tab for screen readers', (tester) async {
    await pumpSaaf(
      tester,
      const SaafMainNav(current: SaafMainTab.home, child: SizedBox()),
      scaffold: false,
    );
    for (final label in ['Home', 'Scan', 'Progress', 'Profile']) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('labels are translated', (tester) async {
    await pumpSaaf(
      tester,
      const SaafMainNav(current: SaafMainTab.home, child: SizedBox()),
      scaffold: false,
      locale: const Locale('ur'),
    );
    expect(find.byTooltip('ہوم'), findsOneWidget);
    expect(find.byTooltip('پروفائل'), findsOneWidget);
  });

  testWidgets('wide screens get the rail with the right tab selected', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const SaafMainNav(current: SaafMainTab.progress, child: SizedBox()),
      scaffold: false,
      size: const Size(1280, 800),
    );
    final rail = tester.widget<NavigationRail>(
      find.byKey(const ValueKey('saaf-nav-rail')),
    );
    expect(rail.selectedIndex, SaafMainTab.progress.index);
    expect(rail.destinations.length, 4);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SaafMainNav(current: SaafMainTab.home, child: SizedBox()),
      scaffold: false,
    );
  });
}
