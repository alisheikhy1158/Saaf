// Covers: design.md §6 SaafProgressBar (6 dp, r3, track ink@0.08 / cornsilk@0.15
// on ink, sage fill), A11Y-4 (value exposed)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester,
    double value, {
    bool onInk = false,
  }) => pumpSaaf(
    tester,
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 200,
        child: SaafProgressBar(value: value, onInk: onInk),
      ),
    ),
  );

  testWidgets('is 6 dp high with r3 corners and a faint ink track', (
    tester,
  ) async {
    await pumpBar(tester, 0.4);
    expect(tester.getSize(find.byType(SaafProgressBar)), const Size(200, 6));
    final track = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-progress-track')),
    );
    final decoration = track.decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(3));
    expect(decoration.color?.a, closeTo(0.08, 0.01));
  });

  testWidgets('the sage fill is value × width', (tester) async {
    await pumpBar(tester, 0.4);
    expect(
      tester.getSize(find.byKey(const ValueKey('saaf-progress-fill'))).width,
      closeTo(80, 0.5),
    );
    final fill = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-progress-fill')),
    );
    expect((fill.decoration as BoxDecoration).color, SaafPalette.sage);
  });

  testWidgets('clamps values outside 0–1', (tester) async {
    await pumpBar(tester, 1.7);
    expect(
      tester.getSize(find.byKey(const ValueKey('saaf-progress-fill'))).width,
      200,
    );
    await pumpBar(tester, -1);
    expect(
      tester.getSize(find.byKey(const ValueKey('saaf-progress-fill'))).width,
      0,
    );
  });

  testWidgets('on ink the track is cornsilk @ 15 %', (tester) async {
    await pumpBar(tester, 0.5, onInk: true);
    final track = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('saaf-progress-track')),
    );
    expect((track.decoration as BoxDecoration).color?.a, closeTo(0.15, 0.01));
  });

  testWidgets('exposes the percentage to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBar(tester, 0.4);
    expect(
      tester.getSemantics(find.byType(SaafProgressBar)),
      isSemantics(value: '40%'),
    );
    handle.dispose();
  });

  testWidgets('fills from the right in RTL', (tester) async {
    await pumpSaaf(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 200, child: SaafProgressBar(value: 0.4)),
      ),
      locale: const Locale('ur'),
    );
    final bar = tester.getRect(find.byType(SaafProgressBar));
    final fill = tester.getRect(
      find.byKey(const ValueKey('saaf-progress-fill')),
    );
    expect(fill.right, closeTo(bar.right, 0.5));
  });
}
