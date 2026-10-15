// Covers: design.md §6 SaafOptionTile (r18, padding 14, gap 14, 40 dp icon circle,
// title 15/20/800 + caption 12/16, trailing 24 dp check; unselected 1 dp ink@0.10
// border + sageTint circle; selected 1.5 dp ink border + sage circle),
// §9.1 (whole tile tappable), A11Y-1/3/7
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';

import '../../../helpers/pump_app.dart';

Widget tile({bool selected = false, VoidCallback? onTap}) => SaafOptionTile(
  icon: Icons.water_drop_outlined,
  title: 'Oiliness & large pores',
  caption: 'Shiny by midday',
  selected: selected,
  onTap: onTap ?? () {},
);

void main() {
  BoxDecoration tileDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-option-box')),
    );
    return box.decoration as BoxDecoration;
  }

  testWidgets(
    'unselected: 1 dp faint border, sage-tint circle with sage icon',
    (tester) async {
      await pumpSaaf(tester, tile());
      final border = tileDecoration(tester).border! as Border;
      expect(border.top.width, 1);
      expect(border.top.color.a, closeTo(0.10, 0.01));
      expect(tileDecoration(tester).borderRadius, BorderRadius.circular(18));
      final circle = tester.widget<SaafIconCircle>(find.byType(SaafIconCircle));
      expect(circle.tone, SaafIconCircleTone.sageTint);
      expect(circle.iconColor, SaafIconCircleColor.sage);
      expect(tester.widget<SaafCheck>(find.byType(SaafCheck)).checked, isFalse);
    },
  );

  testWidgets('selected: 1.5 dp ink border, sage circle with ink icon, tick', (
    tester,
  ) async {
    await pumpSaaf(tester, tile(selected: true));
    final border = tileDecoration(tester).border! as Border;
    expect(border.top.width, 1.5);
    expect(border.top.color, SaafPalette.ink);
    final circle = tester.widget<SaafIconCircle>(find.byType(SaafIconCircle));
    expect(circle.tone, SaafIconCircleTone.sage);
    expect(circle.iconColor, SaafIconCircleColor.ink);
    expect(tester.widget<SaafCheck>(find.byType(SaafCheck)).checked, isTrue);
  });

  testWidgets('uses the Figma text styles', (tester) async {
    await pumpSaaf(tester, tile());
    final title = tester.widget<Text>(find.text('Oiliness & large pores'));
    expect(title.style?.fontSize, 15);
    expect(title.style?.fontWeight, FontWeight.w800);
    final caption = tester.widget<Text>(find.text('Shiny by midday'));
    expect(caption.style?.fontSize, 12);
    expect(caption.style?.color?.a, closeTo(0.55, 0.01));
  });

  testWidgets('the 40 dp icon circle and 24 dp check sit in a 14 dp padding', (
    tester,
  ) async {
    await pumpSaaf(tester, tile());
    expect(tester.getSize(find.byType(SaafIconCircle)), const Size(40, 40));
    expect(tester.getSize(find.byType(SaafCheck)), const Size(24, 24));
    final box = tester.getRect(find.byKey(const ValueKey('saaf-option-box')));
    final circle = tester.getRect(find.byType(SaafIconCircle));
    expect(circle.left - box.left, 14);
  });

  testWidgets('the whole tile is tappable', (tester) async {
    var taps = 0;
    await pumpSaaf(tester, tile(onTap: () => taps++));
    await tester.tap(find.text('Shiny by midday'));
    await tester.tap(find.byType(SaafCheck));
    await tester.tap(find.byType(SaafIconCircle));
    expect(taps, 3);
  });

  testWidgets('is one checkbox for screen readers, named title then caption', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, tile(selected: true));
    expect(
      tester.getSemantics(
        find.bySemanticsLabel('Oiliness & large pores. Shiny by midday'),
      ),
      isSemantics(
        label: 'Oiliness & large pores. Shiny by midday',
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(tester, tile());
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => Column(
        spacing: 10,
        children: [
          SaafOptionTile(
            icon: Icons.auto_awesome_outlined,
            title: 'Dark spots & pigmentation',
            caption: 'Marks left by acne or the sun',
            selected: true,
            onTap: () {},
          ),
          tile(),
        ],
      ),
    );
  });
}
