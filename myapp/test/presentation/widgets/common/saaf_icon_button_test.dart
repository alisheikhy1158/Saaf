// Covers: design.md §6 SaafIconButton (40 dp circle, 1 dp ink@0.12, 20 dp icon,
// on-dark fill), §9.1 (48 dp hit area), A11Y-1 (tooltip + label required)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Size visualSize(WidgetTester tester) => tester.getSize(
    find
        .descendant(
          of: find.byType(IconButton),
          matching: find.byType(Material),
        )
        .first,
  );

  testWidgets('is drawn 40×40 with a 20 dp icon', (tester) async {
    await pumpSaaf(
      tester,
      Center(
        child: SaafIconButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () {},
        ),
      ),
    );
    expect(visualSize(tester), const Size(40, 40));
    // The icon size comes from the button style, so measure what is drawn.
    expect(tester.getSize(find.byIcon(Icons.arrow_back)), const Size(20, 20));
  });

  testWidgets('hit area is at least 48×48 while the visual stays 40', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      Center(
        child: SaafIconButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () {},
        ),
      ),
    );
    final hit = tester.getSize(find.byType(IconButton));
    expect(hit.width, greaterThanOrEqualTo(48));
    expect(hit.height, greaterThanOrEqualTo(48));
  });

  testWidgets('has a tooltip and fires onPressed', (tester) async {
    var taps = 0;
    await pumpSaaf(
      tester,
      Center(
        child: SaafIconButton(
          icon: Icons.notifications_none,
          tooltip: 'Notifications',
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byTooltip('Notifications'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 1);
  });

  testWidgets('on-dark variant uses a translucent cornsilk fill', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      Center(
        child: SaafIconButton(
          icon: Icons.close,
          tooltip: 'Close',
          onDark: true,
          onPressed: () {},
        ),
      ),
    );
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(IconButton),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color?.a, closeTo(0.12, 0.01));
  });

  testWidgets('passes the accessibility guidelines', (tester) async {
    await pumpSaaf(
      tester,
      Center(
        child: SaafIconButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () {},
        ),
      ),
    );
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => Row(
        children: [
          SaafIconButton(
            icon: Icons.arrow_back,
            tooltip: 'Back',
            onPressed: () {},
          ),
          const Spacer(),
          SaafIconButton(
            icon: Icons.settings,
            tooltip: 'Settings',
            onDark: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  });
}
