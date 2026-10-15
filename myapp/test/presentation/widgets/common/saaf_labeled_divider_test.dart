// Covers: Figma 02 "Divider" (1 dp ink@0.10 lines either side of "or" 13/400
// ink@0.5, gap 12)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_labeled_divider.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('draws two 1 dp lines around the label', (tester) async {
    await pumpSaaf(tester, const SaafLabeledDivider(label: 'or'));
    final left = tester.getRect(
      find.byKey(const ValueKey('saaf-divider-start')),
    );
    final right = tester.getRect(
      find.byKey(const ValueKey('saaf-divider-end')),
    );
    final label = tester.getRect(find.text('or'));
    expect(left.height, 1);
    expect(right.height, 1);
    expect(label.left - left.right, 12);
    expect(right.left - label.right, 12);
  });

  testWidgets('lines are ink @ 10 % and the label is ink @ 50 %', (
    tester,
  ) async {
    await pumpSaaf(tester, const SaafLabeledDivider(label: 'or'));
    final line = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('saaf-divider-start')),
    );
    expect(line.color.a, closeTo(0.10, 0.01));
    final text = tester.widget<Text>(find.text('or'));
    expect(text.style?.color?.a, closeTo(0.50, 0.01));
    expect(text.style?.fontSize, 13);
  });

  testWidgets('is hidden from screen readers (decorative)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, const SaafLabeledDivider(label: 'or'));
    expect(find.bySemanticsLabel('or'), findsNothing);
    handle.dispose();
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SaafLabeledDivider(label: 'or'),
    );
  });
}
