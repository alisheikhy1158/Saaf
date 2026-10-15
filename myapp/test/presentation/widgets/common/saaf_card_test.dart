// Covers: design.md §6 SaafCard / list group (cornsilk, 1 dp ink@0.09, r20)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('wraps its child in a cornsilk r20 card with a hairline border', (
    tester,
  ) async {
    await pumpSaaf(tester, const SaafCard(child: Text('Hello')));
    expect(find.text('Hello'), findsOneWidget);

    // The shape comes from ThemeData.cardTheme, so read what is rendered.
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(Card), matching: find.byType(Material)),
    );
    final shape = material.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(20));
    expect(shape.side.width, 1);
    expect(
      shape.side.color,
      SaafTheme.light().extension<SaafTokens>()!.borderCard,
    );
  });

  testWidgets('applies the default inner padding', (tester) async {
    await pumpSaaf(tester, const SaafCard(child: Text('Hello')));
    final padding = tester.widget<Padding>(
      find
          .ancestor(of: find.text('Hello'), matching: find.byType(Padding))
          .first,
    );
    expect(padding.padding, const EdgeInsetsDirectional.all(20));
  });

  testWidgets('is tappable when onTap is given, with button semantics', (
    tester,
  ) async {
    var taps = 0;
    await pumpSaaf(
      tester,
      SaafCard(
        onTap: () => taps++,
        semanticLabel: 'Open details',
        child: const Text('Hello'),
      ),
    );
    await tester.tap(find.byType(SaafCard));
    expect(taps, 1);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SaafCard(
        child: Text(
          'A long line of card content that has to wrap at 200 % text size without overflowing',
        ),
      ),
    );
  });
}
