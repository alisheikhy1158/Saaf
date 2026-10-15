// Covers: design.md §6 SaafTextField (label above, 56 dp, r14, prefix + divider,
// valid check, helper row), §9.6 (error state), A11Y-1, A11Y-6, A11Y-8, SEC-8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the label above a 56 dp tall field', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', hintText: '300 1234567'),
    );
    expect(find.text('Mobile number'), findsOneWidget);
    final label = tester.getTopLeft(find.text('Mobile number'));
    final field = tester.getTopLeft(find.byType(TextField));
    expect(label.dy, lessThan(field.dy));
    expect(tester.getSize(find.byType(TextField)).height, 56);
  });

  testWidgets('reports typed text through onChanged', (tester) async {
    String? value;
    await pumpSaaf(
      tester,
      SaafTextField(label: 'Mobile number', onChanged: (v) => value = v),
    );
    await tester.enterText(find.byType(TextField), '3001234567');
    expect(value, '3001234567');
  });

  testWidgets('shows a prefix followed by a 1×24 divider', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', prefixText: '+92'),
    );
    expect(find.text('+92'), findsOneWidget);
    final divider = tester.getSize(
      find.byKey(const ValueKey('saaf-field-divider')),
    );
    expect(divider, const Size(1, 24));
  });

  testWidgets('valid state shows a 22 dp sage check', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', isValid: true),
    );
    final check = find.byKey(const ValueKey('saaf-field-valid'));
    expect(check, findsOneWidget);
    expect(tester.getSize(check), const Size(22, 22));
    final decoration = tester.widget<DecoratedBox>(
      find.descendant(of: check, matching: find.byType(DecoratedBox)).first,
    );
    expect((decoration.decoration as BoxDecoration).color, SaafPalette.sage);
  });

  testWidgets('helper row shows a 14 dp icon and caption text', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(
        label: 'Mobile number',
        helperText: "We'll text you a code",
        helperIcon: Icons.lock_outline,
      ),
    );
    expect(find.text("We'll text you a code"), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(Icons.lock_outline)).size, 14);
  });

  testWidgets('error text replaces the helper and uses the error colour', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const SaafTextField(
        label: 'Mobile number',
        helperText: 'Helper',
        errorText: 'Enter a valid number',
      ),
    );
    expect(find.text('Helper'), findsNothing);
    final text = tester.widget<Text>(find.text('Enter a valid number'));
    expect(text.style?.color, SaafPalette.errorLight);
    // Not conveyed by colour alone (A11Y-7): there is an icon too.
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('exposes the label to assistive technology', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', hintText: '300 1234567'),
    );
    expect(find.bySemanticsLabel(RegExp('Mobile number')), findsWidgets);
    handle.dispose();
  });

  testWidgets('disabled field ignores input', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', enabled: false),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(
      tester,
      const SaafTextField(label: 'Mobile number', prefixText: '+92'),
    );
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SaafTextField(
        label: 'Mobile number',
        prefixText: '+92',
        hintText: '300 1234567',
        isValid: true,
        helperText:
            'A rather long helper sentence that must wrap at 200 percent',
        helperIcon: Icons.lock_outline,
      ),
    );
  });
}
