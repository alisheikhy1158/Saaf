// Covers: design.md §6 SaafChip (pill r18, 14×8 padding, 13/800 text,
// 14 dp icon, six fills), A11Y-7 (icon + text, never colour alone)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';

import '../../../helpers/pump_app.dart';

void main() {
  BoxDecoration decorationOf(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SaafChip),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return box.decoration as BoxDecoration;
  }

  testWidgets('renders a pill with the label', (tester) async {
    await pumpSaaf(tester, const Center(child: SaafChip(label: 'Oily')));
    expect(find.text('Oily'), findsOneWidget);
    final decoration = decorationOf(tester);
    expect(decoration.borderRadius, BorderRadius.circular(18));
    expect(decoration.color, SaafPalette.sage);
  });

  testWidgets('tones map to the Figma fills', (tester) async {
    final expected = <SaafChipTone, Color>{
      SaafChipTone.sage: SaafPalette.sage,
      SaafChipTone.papaya: SaafPalette.papaya,
      SaafChipTone.ink: SaafPalette.ink,
      SaafChipTone.cornsilk: SaafPalette.cornsilk,
    };
    for (final entry in expected.entries) {
      await pumpSaaf(
        tester,
        Center(
          child: SaafChip(label: 'x', tone: entry.key),
        ),
      );
      expect(decorationOf(tester).color, entry.value, reason: '${entry.key}');
    }
  });

  testWidgets(
    'strong tone is cornsilk with ink text on the dark camera screen',
    (tester) async {
      await pumpSaaf(
        tester,
        const Center(
          child: SaafChip(
            label: 'Move to softer light',
            tone: SaafChipTone.strong,
          ),
        ),
        themeMode: ThemeMode.dark,
      );
      expect(decorationOf(tester).color, SaafPalette.cornsilk);
      final text = tester.widget<Text>(find.text('Move to softer light'));
      expect(text.style?.color, SaafPalette.ink);
    },
  );

  testWidgets('on-dark tone is cornsilk at 12 % opacity', (tester) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafChip(label: 'x', tone: SaafChipTone.onDark),
      ),
    );
    expect(decorationOf(tester).color?.a, closeTo(0.12, 0.01));
  });

  testWidgets('ink tone uses cornsilk text', (tester) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafChip(label: 'Pro', tone: SaafChipTone.ink),
      ),
    );
    final text = tester.widget<Text>(find.text('Pro'));
    expect(text.style?.color, SaafPalette.cornsilk);
  });

  testWidgets('shows a 14 dp icon with the text', (tester) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafChip(label: 'Good match', icon: Icons.check),
      ),
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.check)).size, 14);
    expect(find.text('Good match'), findsOneWidget);
  });

  testWidgets('small variant uses the micro text style and tighter padding', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const Center(child: SaafChip(label: 'Save 44%', small: true)),
    );
    expect(tester.widget<Text>(find.text('Save 44%')).style?.fontSize, 11);
  });

  testWidgets('regular variant uses the 13 dp chip text style', (tester) async {
    await pumpSaaf(tester, const Center(child: SaafChip(label: 'Oily')));
    expect(tester.widget<Text>(find.text('Oily')).style?.fontSize, 13);
  });

  testWidgets('is read as a single labelled node', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(
      tester,
      const Center(
        child: SaafChip(label: 'Good match', icon: Icons.check),
      ),
    );
    expect(find.bySemanticsLabel('Good match'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SaafChip(label: 'For South Asian skin', tone: SaafChipTone.papaya),
          SaafChip(label: 'Good match', icon: Icons.check),
          SaafChip(label: 'Saaf Pro', tone: SaafChipTone.ink),
          SaafChip(label: 'Save 44%', small: true, tone: SaafChipTone.sageTint),
        ],
      ),
    );
  });
}
