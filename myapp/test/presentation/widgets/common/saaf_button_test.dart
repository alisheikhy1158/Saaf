// Covers: design.md §6 SaafButton (56 dp, r28, sage / outline 1.5 dp / text),
// §8 (disabled = 50 %, spinner for actions), A11Y-1, A11Y-5, A11Y-6, A11Y-8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('primary', () {
    testWidgets('is a 56 dp tall, full-width, r28 sage button', (tester) async {
      await pumpSaaf(
        tester,
        Center(
          child: SaafButton.primary(label: 'Continue', onPressed: () {}),
        ),
      );
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, 56);
      expect(size.width, 390);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(
        button.style?.backgroundColor,
        isNull,
        reason: 'colours come from ThemeData, not per-widget styles',
      );
      final context = tester.element(find.byType(FilledButton));
      expect(Theme.of(context).colorScheme.primary, SaafPalette.sage);
    });

    testWidgets('shows the label and fires onPressed', (tester) async {
      var taps = 0;
      await pumpSaaf(
        tester,
        SaafButton.primary(label: 'Continue', onPressed: () => taps++),
      );
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 1);
    });

    testWidgets('shows a trailing arrow when asked', (tester) async {
      await pumpSaaf(
        tester,
        SaafButton.primary(
          label: 'Continue',
          trailingIcon: Icons.arrow_forward,
          onPressed: () {},
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_forward));
      expect(icon.size, 20);
      expect(
        icon.icon?.matchTextDirection,
        isTrue,
        reason: 'arrow mirrors in RTL',
      );
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await pumpSaaf(
        tester,
        const SaafButton.primary(label: 'Continue', onPressed: null),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );
    });

    testWidgets('loading shows a spinner and ignores taps', (tester) async {
      var taps = 0;
      await pumpSaaf(
        tester,
        SaafButton.primary(
          label: 'Continue',
          isLoading: true,
          onPressed: () => taps++,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
    });
  });

  group('outline', () {
    testWidgets('is 56 dp tall with an optional leading icon', (tester) async {
      await pumpSaaf(
        tester,
        SaafButton.outline(
          // Short on purpose: tests render with the 16 dp-wide Ahem font.
          label: 'Google',
          leadingIcon: Icons.g_mobiledata,
          onPressed: () {},
        ),
      );
      expect(tester.getSize(find.byType(OutlinedButton)).height, 56);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('draws a 1.5 dp ink border from the theme', (tester) async {
      await pumpSaaf(
        tester,
        SaafButton.outline(label: 'Scan', onPressed: () {}),
      );
      final side = SaafTheme.light().outlinedButtonTheme.style!.side!.resolve(
        {},
      );
      expect(side?.width, 1.5);
      expect(side?.color, SaafPalette.ink);
    });
  });

  group('text', () {
    testWidgets('has no fill and a 48 dp hit area', (tester) async {
      await pumpSaaf(tester, SaafButton.text(label: 'Skip', onPressed: () {}));
      expect(find.byType(TextButton), findsOneWidget);
      expect(
        tester.getSize(find.byType(TextButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  testWidgets('hit areas and labels pass the accessibility guidelines', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      Column(
        children: [
          SaafButton.primary(label: 'Continue', onPressed: () {}),
          SaafButton.outline(label: 'Google', onPressed: () {}),
          SaafButton.text(label: 'Skip', onPressed: () {}),
        ],
      ),
    );
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => Column(
        children: [
          SaafButton.primary(
            label: 'Continue with a rather long label to force wrapping',
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
          SaafButton.outline(
            label: 'Continue with Google',
            leadingIcon: Icons.g_mobiledata,
            onPressed: () {},
          ),
          SaafButton.text(label: 'Skip', onPressed: () {}),
        ],
      ),
    );
  });
}
