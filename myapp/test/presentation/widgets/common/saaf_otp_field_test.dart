// Covers: design.md §6 SaafOtpField (6 boxes 50×58 r14, 1 dp ink@0.14, digit
// 22/800, active box 1.5 dp ink + 2×24 sage caret), §9.4 (system keyboard +
// SMS autofill via oneTimeCode, paste of 6 digits), A11Y-1/4, A11Y-8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_otp_field.dart';

import '../../../helpers/pump_app.dart';

Widget field({
  String value = '',
  ValueChanged<String>? onChanged,
  bool hasError = false,
}) => SaafOtpField(
  value: value,
  onChanged: onChanged ?? (_) {},
  hasError: hasError,
  semanticLabel: 'Verification code',
);

void main() {
  Finder box(int i) => find.byKey(ValueKey('saaf-otp-box-$i'));

  BoxDecoration decoration(WidgetTester tester, int i) =>
      tester.widget<DecoratedBox>(box(i)).decoration as BoxDecoration;

  testWidgets('shows six 50 × 58 boxes with r14 corners', (tester) async {
    await pumpSaaf(tester, field());
    for (var i = 0; i < 6; i++) {
      expect(tester.getSize(box(i)), const Size(50, 58), reason: 'box $i');
      expect(decoration(tester, i).borderRadius, BorderRadius.circular(14));
    }
    expect(box(6), findsNothing);
  });

  testWidgets('boxes are spread across the full width', (tester) async {
    await pumpSaaf(tester, field());
    expect(tester.getRect(box(0)).left, 0);
    expect(tester.getRect(box(5)).right, 390);
  });

  testWidgets('boxes shrink to fit a 320 dp phone (no overflow)', (
    tester,
  ) async {
    await pumpSaaf(tester, field(), size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    expect(tester.getRect(box(5)).right, lessThanOrEqualTo(320));
  });

  testWidgets('shows the typed digits in the 22 dp ExtraBold style', (
    tester,
  ) async {
    await pumpSaaf(tester, field(value: '4829'));
    for (final digit in ['4', '8', '2', '9']) {
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(SaafOtpField),
          matching: find.text(digit),
        ),
      );
      expect(text.style?.fontSize, 22);
      expect(text.style?.fontWeight, FontWeight.w800);
    }
  });

  testWidgets('the next empty box is active: 1.5 dp ink border and a caret', (
    tester,
  ) async {
    await pumpSaaf(tester, field(value: '4829'));
    final active = decoration(tester, 4).border! as Border;
    expect(active.top.width, 1.5);
    expect(active.top.color, SaafPalette.ink);
    final caret = find.byKey(const ValueKey('saaf-otp-caret'));
    expect(tester.getSize(caret), const Size(2, 24));
    expect(
      tester.widget<DecoratedBox>(caret).decoration,
      isA<BoxDecoration>().having((d) => d.color, 'color', SaafPalette.sage),
    );
    final idle = decoration(tester, 5).border! as Border;
    expect(idle.top.width, 1);
    expect(idle.top.color.a, closeTo(0.14, 0.01));
  });

  testWidgets('with all six digits no box is active', (tester) async {
    await pumpSaaf(tester, field(value: '482913'));
    expect(find.byKey(const ValueKey('saaf-otp-caret')), findsNothing);
    for (var i = 0; i < 6; i++) {
      expect((decoration(tester, i).border! as Border).top.width, 1);
    }
  });

  testWidgets('an error turns every border to the error colour', (
    tester,
  ) async {
    await pumpSaaf(tester, field(value: '482913', hasError: true));
    for (var i = 0; i < 6; i++) {
      expect(
        (decoration(tester, i).border! as Border).top.color,
        SaafPalette.errorLight,
      );
    }
  });

  testWidgets('typing with the system keyboard reports digits only', (
    tester,
  ) async {
    String? latest;
    await pumpSaaf(tester, field(onChanged: (v) => latest = v));
    await tester.enterText(find.byType(TextField), '4a8-2');
    expect(latest, '482');
  });

  testWidgets('pasting a code longer than six digits keeps the first six', (
    tester,
  ) async {
    String? latest;
    await pumpSaaf(tester, field(onChanged: (v) => latest = v));
    await tester.enterText(find.byType(TextField), '48291377');
    expect(latest, '482913');
  });

  testWidgets('tapping the boxes opens the system keyboard', (tester) async {
    await pumpSaaf(tester, field());
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.tap(box(2));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('asks for SMS autofill (one-time code, number keyboard)', (
    tester,
  ) async {
    await pumpSaaf(tester, field());
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.autofillHints, contains(AutofillHints.oneTimeCode));
    expect(input.keyboardType, TextInputType.number);
  });

  testWidgets('is one labelled text field for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, field(value: '4829'));
    expect(find.bySemanticsLabel(RegExp('Verification code')), findsWidgets);
    expect(find.bySemanticsLabel('4'), findsNothing);
    handle.dispose();
  });

  testWidgets('digit order stays left-to-right in RTL', (tester) async {
    await pumpSaaf(tester, field(value: '482913'), locale: const Locale('ur'));
    expect(
      tester.getRect(find.text('4')).left,
      lessThan(tester.getRect(find.text('3')).left),
    );
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, () => field(value: '4829'));
  });
}
