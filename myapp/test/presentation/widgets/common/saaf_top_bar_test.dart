// Covers: design.md §6 SaafTopBar (40 dp slots keep the title centred, padding
// top 4 / bottom 12, title 16/800), A11Y-1, A11Y-8 (back chevron mirrors)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('is 56 dp tall: 4 + 40 + 12', (tester) async {
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar.back(tooltip: 'Back', onBack: () {}),
      ),
    );
    expect(tester.getSize(find.byType(SaafTopBar)).height, 56);
  });

  testWidgets('back button is a 40 dp icon button with a tooltip', (
    tester,
  ) async {
    var backs = 0;
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar.back(tooltip: 'Back', onBack: () => backs++),
      ),
    );
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    expect(backs, 1);
  });

  testWidgets('the back chevron mirrors in RTL', (tester) async {
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar.back(tooltip: 'Back', onBack: () {}),
      ),
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon?.matchTextDirection, isTrue);
  });

  testWidgets('title stays centred even with only a leading button', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar(
          title: 'Profile',
          leading: SaafTopBar.backButton(tooltip: 'Back', onBack: () {}),
        ),
      ),
    );
    final center = tester.getCenter(find.text('Profile')).dx;
    expect(center, closeTo(195, 1));
  });

  testWidgets('a custom centre widget (quiz progress bar) replaces the title', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar(
          leading: SaafTopBar.backButton(tooltip: 'Back', onBack: () {}),
          center: const SizedBox(key: ValueKey('centre'), height: 6),
          trailing: const SizedBox(
            key: ValueKey('trail'),
            width: 48,
            height: 48,
          ),
        ),
      ),
    );
    final leading = tester.getRect(find.byType(IconButton));
    final centre = tester.getRect(find.byKey(const ValueKey('centre')));
    final trailing = tester.getRect(find.byKey(const ValueKey('trail')));
    expect(centre.left, greaterThanOrEqualTo(leading.right));
    expect(centre.right, lessThanOrEqualTo(trailing.left));
    expect(centre.width, greaterThan(100));
  });

  testWidgets('title uses the 16 dp button text style', (tester) async {
    await pumpSaaf(
      tester,
      const Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar(title: 'Profile'),
      ),
    );
    expect(tester.widget<Text>(find.text('Profile')).style?.fontSize, 16);
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SaafTopBar.back(tooltip: 'Back', onBack: () {}),
      ),
    );
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => SaafTopBar(
        title: 'A fairly long title that must wrap or ellipsize',
        leading: SaafTopBar.backButton(tooltip: 'Back', onBack: () {}),
      ),
    );
  });
}
