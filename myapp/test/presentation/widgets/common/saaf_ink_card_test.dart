// Covers: design.md §6 SaafInkCard (07 score card: ink, r24, 20 dp padding)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('is an ink card with r24 corners and 20 dp padding', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SaafInkCard(child: SizedBox(width: 100, height: 50)),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(SaafInkCard),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, SaafPalette.ink);
    expect(decoration.borderRadius, BorderRadius.circular(24));
    expect(tester.getSize(find.byType(SaafInkCard)), const Size(140, 90));
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SaafInkCard(child: Text('Good base, two things to work on')),
    );
  });
}
