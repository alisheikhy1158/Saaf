// Covers: design.md §6 SaafCheck / SaafCheckRow (24 dp r7 sage box, 14 dp check,
// 12 dp gap, 14/20/700 label), §9.1 (whole row tappable, ≥ 48 dp), A11Y-1/3/7
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_check_row.dart';

import '../../../helpers/pump_app.dart';

Widget row({
  bool value = false,
  ValueChanged<bool>? onChanged,
  Map<String, VoidCallback> actions = const {},
}) => SaafCheckRow(
  value: value,
  onChanged: onChanged ?? (_) {},
  label: const Text('I am 16 or older'),
  semanticLabel: 'I am 16 or older',
  customActions: actions,
);

void main() {
  BoxDecoration boxDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-check-box')),
    );
    return box.decoration as BoxDecoration;
  }

  testWidgets('unchecked: 24 dp box with a 1.5 dp faint border, no tick', (
    tester,
  ) async {
    await pumpSaaf(tester, row());
    expect(
      tester.getSize(find.byKey(const ValueKey('saaf-check-box'))),
      const Size(24, 24),
    );
    final decoration = boxDecoration(tester);
    expect(decoration.color, isNull);
    expect((decoration.border! as Border).top.width, 1.5);
    expect((decoration.border! as Border).top.color.a, closeTo(0.25, 0.01));
    expect(decoration.borderRadius, BorderRadius.circular(7));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('checked: sage fill with a 14 dp ink tick', (tester) async {
    await pumpSaaf(tester, row(value: true));
    expect(boxDecoration(tester).color, SaafPalette.sage);
    final tick = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(tick.size, 14);
    expect(tick.color, SaafPalette.ink);
  });

  testWidgets('tapping the label toggles it (whole row is the hit area)', (
    tester,
  ) async {
    bool? latest;
    await pumpSaaf(tester, row(onChanged: (v) => latest = v));
    await tester.tap(find.text('I am 16 or older'));
    expect(latest, isTrue);

    await pumpSaaf(tester, row(value: true, onChanged: (v) => latest = v));
    await tester.tap(find.byKey(const ValueKey('saaf-check-box')));
    expect(latest, isFalse);
  });

  testWidgets('the row is at least 48 dp tall', (tester) async {
    await pumpSaaf(tester, row());
    expect(
      tester.getSize(find.byType(SaafCheckRow)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('announces label and checked state as one control', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, row(value: true));
    expect(
      tester.getSemantics(find.bySemanticsLabel('I am 16 or older')),
      isSemantics(
        label: 'I am 16 or older',
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('exposes link actions to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    var opened = 0;
    await pumpSaaf(tester, row(actions: {'Open Terms of Use': () => opened++}));
    final data = tester
        .getSemantics(find.bySemanticsLabel('I am 16 or older'))
        .getSemanticsData();
    expect(data.customSemanticsActionIds, isNotEmpty);
    expect(opened, 0);
    handle.dispose();
  });

  testWidgets('the tick is not the only state signal: the semantics say so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, row());
    expect(
      tester.getSemantics(find.bySemanticsLabel('I am 16 or older')),
      isSemantics(hasCheckedState: true, isChecked: false),
    );
    handle.dispose();
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(tester, row());
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => Column(
        children: [
          SaafCheckRow(
            value: true,
            onChanged: (_) {},
            label: const Text(
              'I agree to the Terms of Use and Privacy Policy, which are long',
            ),
            semanticLabel: 'I agree',
          ),
          row(),
        ],
      ),
    );
  });
}
