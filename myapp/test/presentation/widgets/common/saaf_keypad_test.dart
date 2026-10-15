// Covers: design.md §6 SaafOtpField keypad (3×4, keys 24/24/700, padding v14,
// row gap 4, 24 dp delete icon), A11Y-1 (each key labelled), A11Y-5 (≥ 48 dp)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_keypad.dart';

import '../../../helpers/pump_app.dart';

Widget keypad({
  ValueChanged<int>? onDigit,
  VoidCallback? onDelete,
  bool enabled = true,
}) => SaafKeypad(
  onDigit: onDigit ?? (_) {},
  onDelete: onDelete ?? () {},
  deleteLabel: 'Delete',
  enabled: enabled,
);

void main() {
  testWidgets('has the digits 1–9, 0 and a delete key', (tester) async {
    await pumpSaaf(tester, keypad());
    for (var d = 0; d <= 9; d++) {
      expect(find.text('$d'), findsOneWidget, reason: 'digit $d');
    }
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    expect(
      tester.getSize(find.byIcon(Icons.backspace_outlined)),
      const Size(24, 24),
    );
  });

  testWidgets('keys use the 24 dp Bold keypad style', (tester) async {
    await pumpSaaf(tester, keypad());
    final style = tester.widget<Text>(find.text('5')).style!;
    expect(style.fontSize, 24);
    expect(style.fontWeight, FontWeight.w700);
  });

  testWidgets('reports digits and delete', (tester) async {
    final digits = <int>[];
    var deletes = 0;
    await pumpSaaf(
      tester,
      keypad(onDigit: digits.add, onDelete: () => deletes++),
    );
    await tester.tap(find.text('1'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('7'));
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    expect(digits, [1, 0, 7]);
    expect(deletes, 1);
  });

  testWidgets('3 columns × 4 rows with a 4 dp gap between rows', (
    tester,
  ) async {
    await pumpSaaf(tester, keypad());
    final one = tester.getRect(find.byKey(const ValueKey('saaf-key-1')));
    final four = tester.getRect(find.byKey(const ValueKey('saaf-key-4')));
    final two = tester.getRect(find.byKey(const ValueKey('saaf-key-2')));
    expect(four.top - one.bottom, closeTo(4, 0.001));
    expect(two.left - one.right, closeTo(4, 0.001));
    expect(one.height, 52, reason: '14 + 24 + 14');
  });

  testWidgets('the empty cell does nothing', (tester) async {
    var calls = 0;
    await pumpSaaf(
      tester,
      keypad(onDigit: (_) => calls++, onDelete: () => calls++),
    );
    await tester.tap(find.byKey(const ValueKey('saaf-key-blank')));
    expect(calls, 0);
  });

  testWidgets('keys are ignored while disabled', (tester) async {
    var calls = 0;
    await pumpSaaf(tester, keypad(onDigit: (_) => calls++, enabled: false));
    await tester.tap(find.text('3'));
    expect(calls, 0);
  });

  testWidgets('keeps the 1-2-3 layout in right-to-left languages', (
    tester,
  ) async {
    await pumpSaaf(tester, keypad(), locale: const Locale('ur'));
    expect(
      tester.getRect(find.byKey(const ValueKey('saaf-key-1'))).left,
      lessThan(tester.getRect(find.byKey(const ValueKey('saaf-key-3'))).left),
    );
  });

  testWidgets('every key is announced, including Delete', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, keypad());
    expect(find.bySemanticsLabel('Delete'), findsOneWidget);
    expect(find.bySemanticsLabel('8'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(tester, keypad());
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, keypad);
  });
}
