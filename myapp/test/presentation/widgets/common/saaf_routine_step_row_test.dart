// Covers: design.md §6 SaafRoutineStepRow (08 price, 09 tick), A11Y-1/2/5
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';
import 'package:saaf/presentation/widgets/common/saaf_product_thumbnail.dart';
import 'package:saaf/presentation/widgets/common/saaf_routine_step_row.dart';

import '../../../helpers/pump_app.dart';

Widget row({
  bool isLast = false,
  VoidCallback? onTap,
  bool? checked,
  String? semanticLabel,
}) => SaafRoutineStepRow(
  name: 'Neem Face Wash',
  caption: 'Cleanser · Rs 650',
  isLast: isLast,
  onTap: onTap,
  checked: checked,
  semanticLabel: semanticLabel,
  trailing: const Text('Rs 650'),
);

void main() {
  testWidgets('shows the thumbnail, name, caption and the trailing widget', (
    tester,
  ) async {
    await pumpSaaf(tester, row());
    expect(find.byType(SaafProductThumbnail), findsOneWidget);
    expect(find.text('Neem Face Wash'), findsOneWidget);
    expect(find.text('Cleanser · Rs 650'), findsOneWidget);
    expect(find.text('Rs 650'), findsOneWidget);
  });

  testWidgets('the thumbnail is 48 dp and hidden from screen readers', (
    tester,
  ) async {
    await pumpSaaf(tester, row());
    expect(
      tester.getSize(find.byType(SaafProductThumbnail)),
      const Size(48, 48),
    );
  });

  testWidgets('every row but the last has a hairline under it', (tester) async {
    await pumpSaaf(tester, row());
    BoxDecoration decoration() => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.border != null || d.color == null);
    expect(decoration().border, isNotNull);

    await pumpSaaf(tester, row(isLast: true));
    final hasBorder = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .any((d) => d.border != null);
    expect(hasBorder, isFalse);
  });

  testWidgets('without onTap it is plain text, not a button', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, row());
    expect(find.byType(InkWell), findsNothing);
    handle.dispose();
  });

  testWidgets('with onTap the whole row is one checkbox', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpSaaf(
      tester,
      SaafRoutineStepRow(
        name: 'Neem Face Wash',
        caption: 'Cleanser · Rs 650',
        isLast: true,
        checked: false,
        semanticLabel: 'Neem Face Wash, not done yet',
        onTap: () => taps++,
        trailing: const SaafCheck(checked: false),
      ),
    );
    expect(
      find.bySemanticsLabel('Neem Face Wash, not done yet'),
      findsOneWidget,
    );
    await tester.tap(find.text('Neem Face Wash'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('is at least 48 dp tall', (tester) async {
    await pumpSaaf(tester, row());
    expect(
      tester.getSize(find.byType(SaafRoutineStepRow)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, row);
  });
}
