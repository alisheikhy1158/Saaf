// Covers: design.md §6 SaafSettingsGroup / SaafSettingsRow (14: r20, padding h16
// v2, row v14 gap 12, 20 dp icon, 13 value @0.5, 16 dp chevron), A11Y-1/5/8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/saaf_settings_group.dart';

import '../../../helpers/pump_app.dart';

Widget group({VoidCallback? onTap}) => SaafSettingsGroup(
  rows: [
    SaafSettingsRow(
      icon: Icons.water_drop_outlined,
      title: 'Skin profile',
      value: 'Oily, dark spots',
      onTap: onTap ?? () {},
    ),
    SaafSettingsRow(icon: Icons.language, title: 'Language', onTap: () {}),
  ],
);

void main() {
  testWidgets('shows each title, the value and a chevron per row', (
    tester,
  ) async {
    await pumpSaaf(tester, group());
    expect(find.text('Skin profile'), findsOneWidget);
    expect(find.text('Oily, dark spots'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('rows are at least 48 dp tall; icons are 20 dp', (tester) async {
    await pumpSaaf(tester, group());
    for (final row in tester.widgetList(find.byType(SaafSettingsRow))) {
      expect(row, isA<SaafSettingsRow>());
    }
    expect(
      tester.getSize(find.byType(SaafSettingsRow).first).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byIcon(Icons.water_drop_outlined)),
      const Size(20, 20),
    );
  });

  testWidgets('every row but the last has a line under it', (tester) async {
    await pumpSaaf(tester, group());
    final lines = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .where(
          (d) =>
              d.border is Border &&
              (d.border! as Border).bottom.width > 0 &&
              d.borderRadius == null,
        )
        .length;
    expect(lines, 1);
  });

  testWidgets('tapping a row calls onTap', (tester) async {
    var taps = 0;
    await pumpSaaf(tester, group(onTap: () => taps++));
    await tester.tap(find.text('Skin profile'));
    expect(taps, 1);
  });

  testWidgets('a row is read as "title, value"', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, group());
    expect(
      find.bySemanticsLabel('Skin profile, Oily, dark spots'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Language'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the chevron points to the end in right-to-left', (tester) async {
    await pumpSaaf(tester, group(), locale: const Locale('ur'));
    final chevron = tester.widget<Icon>(find.byIcon(Icons.chevron_right).first);
    expect(chevron.icon!.matchTextDirection, isTrue);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, group);
  });
}
