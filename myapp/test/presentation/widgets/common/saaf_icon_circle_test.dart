// Covers: design.md §6 SaafIconCircle (circle 36–64, centred icon at ~½ size),
// A11Y-2 (decorative by default)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('is a circle of the given size with an icon at half size', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafIconCircle(
          icon: Icons.trending_up,
          size: SaafIconCircleSize.welcome,
          tone: SaafIconCircleTone.tan,
        ),
      ),
    );
    expect(tester.getSize(find.byType(SaafIconCircle)), const Size(38, 38));
    expect(tester.getSize(find.byIcon(Icons.trending_up)), const Size(19, 19));
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SaafIconCircle),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, SaafPalette.tan);
  });

  testWidgets('sizes match Figma: 36, 38, 40, 64', (tester) async {
    for (final (size, expected) in [
      (SaafIconCircleSize.small, 36.0),
      (SaafIconCircleSize.welcome, 38.0),
      (SaafIconCircleSize.regular, 40.0),
      (SaafIconCircleSize.large, 64.0),
    ]) {
      await pumpSaaf(
        tester,
        Center(
          child: SaafIconCircle(icon: Icons.add, size: size),
        ),
      );
      expect(
        tester.getSize(find.byType(SaafIconCircle)),
        Size.square(expected),
        reason: '$size',
      );
    }
  });

  testWidgets('tones: sage, sageTint, tan, lightSage', (tester) async {
    final expected = <SaafIconCircleTone, Color>{
      SaafIconCircleTone.sage: SaafPalette.sage,
      SaafIconCircleTone.tan: SaafPalette.tan,
      SaafIconCircleTone.lightSage: SaafPalette.lightSage,
    };
    for (final entry in expected.entries) {
      await pumpSaaf(
        tester,
        Center(
          child: SaafIconCircle(icon: Icons.add, tone: entry.key),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(SaafIconCircle),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).color, entry.value);
    }
    await pumpSaaf(
      tester,
      const Center(
        child: SaafIconCircle(
          icon: Icons.add,
          tone: SaafIconCircleTone.sageTint,
        ),
      ),
    );
    final tint = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SaafIconCircle),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((tint.decoration as BoxDecoration).color?.a, closeTo(0.10, 0.01));
  });

  testWidgets('does not mirror its icon in RTL unless asked (charts, etc.)', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const Center(child: SaafIconCircle(icon: Icons.trending_up)),
      locale: const Locale('ur'),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.trending_up)).textDirection,
      TextDirection.ltr,
    );

    await pumpSaaf(
      tester,
      const Center(
        child: SaafIconCircle(icon: Icons.arrow_forward, mirrorInRtl: true),
      ),
      locale: const Locale('ur'),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.arrow_forward)).textDirection,
      isNull,
    );
  });

  testWidgets('inkTint tone is ink @ 5 % and iconColor overrides the icon', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const Center(
        child: SaafIconCircle(
          icon: Icons.lock_outline,
          tone: SaafIconCircleTone.inkTint,
        ),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SaafIconCircle),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((box.decoration as BoxDecoration).color?.a, closeTo(0.05, 0.01));
    expect(
      tester.widget<Icon>(find.byIcon(Icons.lock_outline)).color,
      SaafPalette.ink,
    );

    await pumpSaaf(
      tester,
      const Center(
        child: SaafIconCircle(
          icon: Icons.verified_user_outlined,
          size: SaafIconCircleSize.large,
          tone: SaafIconCircleTone.sageTint,
          iconColor: SaafIconCircleColor.sage,
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.verified_user_outlined));
    expect(icon.color, SaafPalette.sage);
    expect(icon.size, 32);
  });

  testWidgets('is decorative: hidden from screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSaaf(
      tester,
      const Center(child: SaafIconCircle(icon: Icons.trending_up)),
    );
    expect(find.byType(ExcludeSemantics), findsWidgets);
    handle.dispose();
  });
}
