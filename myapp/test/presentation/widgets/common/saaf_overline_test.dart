// Covers: design.md §6 SaafOverline (12/800, letter-spacing 0.96, UPPERCASE,
// ink@0.45 — ink 1.0 on 05)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('upper-cases the text in the overline style', (tester) async {
    await pumpSaaf(tester, const SaafOverline('Step 2 of 5'));
    expect(find.text('STEP 2 OF 5'), findsOneWidget);
    final style = tester.widget<Text>(find.text('STEP 2 OF 5')).style!;
    expect(style.fontSize, 12);
    expect(style.letterSpacing, closeTo(0.96, 0.001));
    expect(style.fontWeight, FontWeight.w800);
  });

  testWidgets('is faint by default and full ink when strong', (tester) async {
    await pumpSaaf(tester, const SaafOverline('Routine'));
    expect(
      tester.widget<Text>(find.text('ROUTINE')).style?.color?.a,
      closeTo(0.45, 0.01),
    );
    await pumpSaaf(tester, const SaafOverline('Routine', strong: true));
    expect(
      tester.widget<Text>(find.text('ROUTINE')).style?.color,
      SaafPalette.ink,
    );
  });

  testWidgets('wraps at 200 % text without overflow', (tester) async {
    await pumpSaaf(
      tester,
      const SaafOverline('A rather long overline label that must wrap'),
      size: const Size(320, 568),
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);
  });
}
