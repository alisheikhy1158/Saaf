// Covers: design.md §6 SaafDisclaimer (07: info icon + caption), A11Y-2
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_disclaimer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const text = 'A cosmetic screening, not a medical diagnosis.';

  testWidgets('shows the icon and the text; the icon is not read aloud', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, const SaafDisclaimer(text));
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.bySemanticsLabel(text), findsOneWidget);
    handle.dispose();
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, () => const SaafDisclaimer(text));
  });
}
