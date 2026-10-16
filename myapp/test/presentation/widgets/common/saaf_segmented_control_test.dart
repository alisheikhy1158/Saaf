// Covers: design.md §6 SaafSegmentedControl (track ink@0.04 r26 pad 4 gap 4,
// segment r22 12×10, selected = sage + 16 dp icon), A11Y-1, A11Y-5, A11Y-8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_segmented_control.dart';

import '../../../helpers/pump_app.dart';

const _segments = [
  SaafSegment(label: 'English', icon: Icons.language),
  SaafSegment(label: 'Urdu'),
];

Widget control({int selected = 0, ValueChanged<int>? onChanged}) =>
    SaafSegmentedControl(
      segments: _segments,
      selectedIndex: selected,
      onChanged: onChanged ?? (_) {},
      semanticLabel: 'Language',
    );

void main() {
  testWidgets('shows every label; only the selected segment shows its icon', (
    tester,
  ) async {
    await pumpSaaf(tester, control());
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Urdu'), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(tester.getSize(find.byIcon(Icons.language)), const Size(16, 16));

    await pumpSaaf(tester, control(selected: 1));
    expect(find.byIcon(Icons.language), findsNothing);
  });

  testWidgets('selected segment is sage with ink text, the rest is secondary', (
    tester,
  ) async {
    await pumpSaaf(tester, control());
    final selected = tester.widget<Text>(find.text('English'));
    final other = tester.widget<Text>(find.text('Urdu'));
    expect(selected.style?.color, SaafPalette.ink);
    expect(other.style?.color?.a, closeTo(0.60, 0.01));
    final fill = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('saaf-segment-0')),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((fill.decoration as BoxDecoration).color, SaafPalette.sage);
  });

  testWidgets(
    'ink tone fills the selected segment with ink and cornsilk text',
    (tester) async {
      await pumpSaaf(
        tester,
        SaafSegmentedControl(
          segments: const [
            SaafSegment(label: 'Morning', icon: Icons.wb_sunny_outlined),
            SaafSegment(label: 'Night', icon: Icons.nightlight_outlined),
          ],
          selectedIndex: 0,
          onChanged: (_) {},
          semanticLabel: 'Time of day',
          tone: SaafSegmentTone.ink,
          iconOnEvery: true,
        ),
      );
      final fill = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byKey(const ValueKey('saaf-segment-0')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((fill.decoration as BoxDecoration).color, SaafPalette.ink);
      expect(
        tester.widget<Text>(find.text('Morning')).style?.color,
        SaafPalette.cornsilk,
      );
      // Both segments show their icon, not only the selected one.
      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_outlined), findsOneWidget);
    },
  );

  testWidgets('track is ink@4 % with r26 corners', (tester) async {
    await pumpSaaf(tester, control());
    final track = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-segmented-track')),
    );
    final decoration = track.decoration as BoxDecoration;
    expect(decoration.color?.a, closeTo(0.04, 0.01));
    expect(decoration.borderRadius, BorderRadius.circular(26));
  });

  testWidgets('reports the tapped segment', (tester) async {
    int? tapped;
    await pumpSaaf(tester, control(onChanged: (i) => tapped = i));
    await tester.tap(find.text('Urdu'));
    expect(tapped, 1);
  });

  testWidgets('segments split the width equally', (tester) async {
    await pumpSaaf(tester, control());
    final a = tester.getSize(find.byKey(const ValueKey('saaf-segment-0')));
    final b = tester.getSize(find.byKey(const ValueKey('saaf-segment-1')));
    expect(a.width, closeTo(b.width, 0.5));
  });

  testWidgets('is announced as a group; each segment is a selectable button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(tester, control(selected: 1));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Urdu')),
      isSemantics(
        label: 'Urdu',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('English')),
      isSemantics(label: 'English', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('has 48 dp hit areas', (tester) async {
    await pumpSaaf(tester, control());
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(tester, control);
  });
}
