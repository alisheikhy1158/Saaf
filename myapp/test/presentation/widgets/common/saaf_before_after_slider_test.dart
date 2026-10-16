// Covers: design.md §6 SaafBeforeAfterSlider (12: 300 dp tall, r24, 44 dp handle,
// 2 dp line, "Before" / "After" chips), A11Y (slider semantics, keyboard)
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_before_after_slider.dart';

import '../../../helpers/pump_app.dart';

Widget slider({ValueChanged<double>? onChanged}) => SizedBox(
  width: 350,
  child: SaafBeforeAfterSlider(
    before: const ColoredBox(color: Colors.red, child: SizedBox.expand()),
    after: const ColoredBox(color: Colors.blue, child: SizedBox.expand()),
    beforeLabel: 'Before · 14 Sep',
    afterLabel: 'After · 14 Oct',
    semanticLabel: 'Compare before and after',
    onChanged: onChanged,
  ),
);

Future<void> pump(WidgetTester tester, Widget child, {Locale? locale}) =>
    pumpSaaf(
      tester,
      Align(alignment: Alignment.topLeft, child: child),
      locale: locale ?? const Locale('en'),
    );

void main() {
  testWidgets('is 300 dp tall and shows both labels', (tester) async {
    await pump(tester, slider());
    expect(
      tester.getSize(find.byType(SaafBeforeAfterSlider)),
      const Size(350, 300),
    );
    expect(find.text('Before · 14 Sep'), findsOneWidget);
    expect(find.text('After · 14 Oct'), findsOneWidget);
  });

  testWidgets('starts in the middle, with the handle on the line', (
    tester,
  ) async {
    await pump(tester, slider());
    final handle = tester.getCenter(
      find.byKey(const ValueKey('saaf-compare-handle')),
    );
    expect(handle.dx, closeTo(175, 1));
    expect(
      tester.getSize(find.byKey(const ValueKey('saaf-compare-handle'))),
      const Size(44, 44),
    );
  });

  testWidgets('dragging the handle moves the divider', (tester) async {
    double? last;
    await pump(tester, slider(onChanged: (v) => last = v));
    await tester.drag(
      find.byKey(const ValueKey('saaf-compare-handle')),
      const Offset(70, 0),
    );
    await tester.pump();
    final handle = tester.getCenter(
      find.byKey(const ValueKey('saaf-compare-handle')),
    );
    // A finger drag first spends a few pixels on the touch slop.
    expect(handle.dx, greaterThan(215));
    expect(handle.dx, lessThanOrEqualTo(245));
    expect(last, inInclusiveRange(0.6, 0.7));
  });

  testWidgets('cannot be dragged outside the picture', (tester) async {
    await pump(tester, slider());
    await tester.drag(
      find.byKey(const ValueKey('saaf-compare-handle')),
      const Offset(1000, 0),
    );
    await tester.pump();
    final handle = tester.getCenter(
      find.byKey(const ValueKey('saaf-compare-handle')),
    );
    expect(handle.dx, lessThanOrEqualTo(350));
  });

  testWidgets('arrow keys move it', (tester) async {
    await pump(tester, slider());
    await tester.tap(find.byKey(const ValueKey('saaf-compare-handle')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    final handle = tester.getCenter(
      find.byKey(const ValueKey('saaf-compare-handle')),
    );
    expect(handle.dx, greaterThan(175));
  });

  testWidgets('is a slider for screen readers, with its value and actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, slider());
    final node = tester.getSemantics(
      find.bySemanticsLabel('Compare before and after'),
    );
    final data = node.getSemanticsData();
    expect(data.value, '50%');
    expect(
      data.hasAction(SemanticsAction.increase) &&
          data.hasAction(SemanticsAction.decrease),
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('the handle has a 48 dp hit area', (tester) async {
    await pump(tester, slider());
    final box = tester.getSize(find.byKey(const ValueKey('saaf-compare-hit')));
    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, () => slider());
  });
}
