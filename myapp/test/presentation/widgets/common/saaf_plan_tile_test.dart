// Covers: design.md §6 SaafPlanTile (13 "Plan": r20, padding 18×16, selected 2 dp
// ink border, badge, price 17/800), A11Y-1/5, 48 dp hit area
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_plan_tile.dart';

import '../../../helpers/pump_app.dart';

Widget tile({
  bool selected = true,
  VoidCallback? onTap,
  String? badge = 'Save 44%',
}) => SaafPlanTile(
  title: 'Yearly',
  caption: 'Rs 333/month, billed yearly',
  price: 'Rs 3,999',
  selected: selected,
  onTap: onTap ?? () {},
  badge: badge,
  semanticLabel: 'Yearly. Rs 3,999. Rs 333/month, billed yearly',
);

void main() {
  testWidgets('shows the title, badge, caption and price', (tester) async {
    await pumpSaaf(tester, tile());
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Save 44%'), findsOneWidget);
    expect(find.text('Rs 333/month, billed yearly'), findsOneWidget);
    expect(find.text('Rs 3,999'), findsOneWidget);
  });

  testWidgets('the badge is optional', (tester) async {
    await pumpSaaf(tester, tile(badge: null));
    expect(find.text('Save 44%'), findsNothing);
  });

  testWidgets('selected: 2 dp ink border and a ticked circle', (tester) async {
    await pumpSaaf(tester, tile());
    final box = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-plan-box')),
    );
    final border = (box.decoration as BoxDecoration).border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, SaafPalette.ink);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('not selected: a hairline border and an empty circle', (
    tester,
  ) async {
    await pumpSaaf(tester, tile(selected: false));
    final box = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-plan-box')),
    );
    final border = (box.decoration as BoxDecoration).border! as Border;
    expect(border.top.width, 1);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('tapping anywhere on it selects', (tester) async {
    var taps = 0;
    await pumpSaaf(tester, tile(selected: false, onTap: () => taps++));
    await tester.tap(find.text('Rs 333/month, billed yearly'));
    expect(taps, 1);
  });

  testWidgets('is announced as one checkbox', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, tile());
    expect(
      find.bySemanticsLabel('Yearly. Rs 3,999. Rs 333/month, billed yearly'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, tile);
  });
}
