// Covers: design.md §6 SaafCheck (circle 22/24/26 or r7 box; checked = sage fill
// + ink tick, unchecked = 1.5 dp ink@0.25 outline), A11Y-7 (tick, not colour only)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';

import '../../../helpers/pump_app.dart';

void main() {
  BoxDecoration decoration(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.byKey(const ValueKey('saaf-check-box')),
              )
              .decoration
          as BoxDecoration;

  testWidgets('circle: 24 dp with r12 corners', (tester) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafCheck(checked: false, shape: SaafCheckShape.circle),
      ),
    );
    expect(tester.getSize(find.byType(SaafCheck)), const Size(24, 24));
    expect(decoration(tester).borderRadius, BorderRadius.circular(12));
  });

  testWidgets('rounded box: 24 dp with r7 corners', (tester) async {
    await pumpSaaf(tester, const Center(child: SaafCheck(checked: false)));
    expect(decoration(tester).borderRadius, BorderRadius.circular(7));
  });

  testWidgets('sizes: 22, 24, 26 with 13, 14, 16 dp ticks', (tester) async {
    for (final (size, box, tick) in [
      (SaafCheckSize.small, 22.0, 13.0),
      (SaafCheckSize.medium, 24.0, 14.0),
      (SaafCheckSize.large, 26.0, 16.0),
    ]) {
      await pumpSaaf(
        tester,
        Center(child: SaafCheck(checked: true, size: size)),
      );
      expect(tester.getSize(find.byType(SaafCheck)), Size.square(box));
      expect(tester.widget<Icon>(find.byIcon(Icons.check)).size, tick);
    }
  });

  testWidgets('checked: sage fill, no outline, ink tick', (tester) async {
    await pumpSaaf(tester, const Center(child: SaafCheck(checked: true)));
    expect(decoration(tester).color, SaafPalette.sage);
    expect(decoration(tester).border, isNull);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check)).color,
      SaafPalette.ink,
    );
  });

  testWidgets('unchecked: 1.5 dp outline at 25 % ink, no tick', (tester) async {
    await pumpSaaf(tester, const Center(child: SaafCheck(checked: false)));
    final border = decoration(tester).border! as Border;
    expect(border.top.width, 1.5);
    expect(border.top.color.a, closeTo(0.25, 0.01));
    expect(decoration(tester).color, isNull);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('is decorative: the owning control announces the state', (
    tester,
  ) async {
    await pumpSaaf(tester, const Center(child: SaafCheck(checked: true)));
    expect(
      find.ancestor(
        of: find.byType(DecoratedBox),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
  });
}
