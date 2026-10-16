// Covers: design.md §9.6 SaafStatusMessage (empty and error states), A11Y-1/5
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';

import '../../../helpers/pump_app.dart';

Widget message({VoidCallback? onAction, String? body = 'Try again later.'}) =>
    SingleChildScrollView(
      child: SaafStatusMessage(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        body: body,
        actionLabel: 'Try again',
        onAction: onAction ?? () {},
      ),
    );

void main() {
  testWidgets('shows the icon, title, body and button', (tester) async {
    await pumpSaaf(tester, message());
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again later.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('the body is optional', (tester) async {
    await pumpSaaf(tester, message(body: null));
    expect(find.text('Try again later.'), findsNothing);
    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('the button calls onAction', (tester) async {
    var taps = 0;
    await pumpSaaf(tester, message(onAction: () => taps++));
    await tester.tap(find.text('Try again'));
    expect(taps, 1);
  });

  testWidgets('the title is a heading for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, message());
    expect(
      tester
          .getSemantics(find.text('Something went wrong'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, message);
  });
}
