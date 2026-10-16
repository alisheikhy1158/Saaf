// Covers: design.md §6 SaafProgressRing (07 score ring: 104 dp, 8 dp stroke, sage
// arc on a faint track, value in the middle), A11Y-4
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_ring.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Widget ring({double value = 0.76}) => Center(
    child: SaafProgressRing(
      value: value,
      size: 104,
      stroke: 8,
      semanticLabel: 'Skin score 76 out of 100',
      child: const Text('76'),
    ),
  );

  testWidgets('is as big as asked and shows its child', (tester) async {
    await pumpSaaf(tester, ring());
    expect(tester.getSize(find.byType(SaafProgressRing)), const Size(104, 104));
    expect(find.text('76'), findsOneWidget);
  });

  testWidgets('speaks its label once, not the number inside', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, ring());
    expect(find.bySemanticsLabel('Skin score 76 out of 100'), findsOneWidget);
    expect(find.bySemanticsLabel('76'), findsNothing);
    handle.dispose();
  });

  testWidgets('accepts values outside 0–1 without breaking', (tester) async {
    for (final v in [-1.0, 0.0, 1.0, 2.0]) {
      await pumpSaaf(tester, ring(value: v));
      expect(tester.takeException(), isNull, reason: '$v');
    }
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, ring);
  });
}
