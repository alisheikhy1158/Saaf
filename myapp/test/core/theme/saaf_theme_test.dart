// Covers: design.md §1 (theme architecture), §2.3 (ColorScheme mapping),
// §2.4 (high-contrast), A11Y-5, A11Y-6
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/breakpoints.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/theme/tokens.dart';

/// WCAG contrast ratio of [fg] painted (with its alpha) over opaque [bg].
double contrast(Color fg, Color bg) {
  final blended = Color.alphaBlend(fg, bg);
  final l1 = blended.computeLuminance();
  final l2 = bg.computeLuminance();
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = <String, ThemeData>{
    'light': SaafTheme.light(),
    'dark': SaafTheme.dark(),
    'highContrastLight': SaafTheme.highContrastLight(),
    'highContrastDark': SaafTheme.highContrastDark(),
  };

  group('SaafTokens extension exists in all four themes', () {
    for (final entry in themes.entries) {
      test(entry.key, () {
        expect(entry.value.extension<SaafTokens>(), isNotNull);
        expect(entry.value.useMaterial3, isTrue);
      });
    }
  });

  group('light ColorScheme (design.md §2.3)', () {
    final c = SaafTheme.light().colorScheme;
    test('surface / onSurface', () {
      expect(c.brightness, Brightness.light);
      expect(c.surface, SaafPalette.cornsilk);
      expect(c.onSurface, SaafPalette.ink);
    });
    test('primary / containers', () {
      expect(c.primary, SaafPalette.sage);
      expect(c.onPrimary, SaafPalette.ink);
      expect(c.primaryContainer, SaafPalette.lightSage);
      expect(c.secondaryContainer, SaafPalette.papaya);
      expect(c.tertiary, SaafPalette.tan);
    });
    test('inverse surface is the ink card', () {
      expect(c.inverseSurface, SaafPalette.ink);
      expect(c.onInverseSurface, SaafPalette.cornsilk);
    });
    test('error colour added at build time', () {
      expect(c.error, SaafPalette.errorLight);
    });
  });

  group('dark ColorScheme (design.md §2.3)', () {
    final c = SaafTheme.dark().colorScheme;
    test('ink background, cornsilk text, sage stays the accent', () {
      expect(c.brightness, Brightness.dark);
      expect(c.surface, SaafPalette.ink);
      expect(c.onSurface, SaafPalette.cornsilk);
      expect(c.primary, SaafPalette.sage);
      expect(c.onPrimary, SaafPalette.ink);
      expect(c.error, SaafPalette.errorDark);
    });
  });

  group('typography wiring (design.md §3)', () {
    final t = SaafTheme.light().textTheme;
    test('roles map to the Figma styles', () {
      expect(t.displaySmall?.fontSize, 46);
      expect(t.headlineLarge?.fontSize, 34);
      expect(t.headlineMedium?.fontSize, 30);
      expect(t.headlineSmall?.fontSize, 29);
      expect(t.titleLarge?.fontSize, 24);
      expect(t.titleMedium?.fontSize, 18);
      expect(t.titleSmall?.fontSize, 17);
      expect(t.labelLarge?.fontSize, 16);
      expect(t.bodyLarge?.fontSize, 15);
      expect(t.bodyMedium?.fontSize, 14);
      expect(t.bodySmall?.fontSize, 12);
      expect(t.labelMedium?.fontSize, 13);
      expect(t.labelSmall?.fontSize, 12);
    });

    test('Nunito with Urdu fallback', () {
      expect(t.bodyMedium?.fontFamily, 'Nunito');
      expect(t.bodyMedium?.fontFamilyFallback, ['NotoNaskhArabic']);
    });
  });

  group('SaafTokens values', () {
    test('light ladder is ink @ alpha', () {
      final s = SaafTheme.light().extension<SaafTokens>()!;
      expect(s.textSecondary, SaafPalette.ink.withValues(alpha: 0.60));
      expect(s.textCaption, SaafPalette.ink.withValues(alpha: 0.55));
      expect(s.borderCard, SaafPalette.ink.withValues(alpha: 0.09));
      expect(s.borderFocus, SaafPalette.ink);
      expect(s.sageTint, SaafPalette.sage.withValues(alpha: 0.10));
    });

    test('dark ladder is cornsilk @ alpha', () {
      final s = SaafTheme.dark().extension<SaafTokens>()!;
      expect(s.textSecondary, SaafPalette.cornsilk.withValues(alpha: 0.60));
      expect(s.borderFocus, SaafPalette.cornsilk);
    });

    test(
      'controlOnInk is cornsilk @ 12 % in every theme (06 icon buttons)',
      () {
        for (final theme in themes.values) {
          expect(
            theme.extension<SaafTokens>()!.controlOnInk,
            SaafPalette.cornsilk.withValues(alpha: 0.12),
          );
        }
      },
    );

    test('exposes spacing, radius, size and motion tokens', () {
      final s = SaafTheme.light().extension<SaafTokens>()!;
      expect(s.space.gutter, 20);
      expect(s.radius.r28, 28);
      expect(s.size.button, 56);
      expect(s.motion.medium, const Duration(milliseconds: 250));
    });

    test('copyWith overrides only the given field', () {
      final s = SaafTheme.light().extension<SaafTokens>()!;
      final copy = s.copyWith(textMeta: const Color(0xFF000000));
      expect(copy.textMeta, const Color(0xFF000000));
      expect(copy.textCaption, s.textCaption);
    });

    test('lerp(0) is this, lerp(1) is other', () {
      final a = SaafTheme.light().extension<SaafTokens>()!;
      final b = SaafTheme.dark().extension<SaafTokens>()!;
      expect(a.lerp(b, 0).textSecondary, a.textSecondary);
      expect(a.lerp(b, 1).textSecondary, b.textSecondary);
    });
  });

  group('high contrast (design.md §2.4, A11Y-5)', () {
    for (final entry in {
      'highContrastLight': SaafTheme.highContrastLight(),
      'highContrastDark': SaafTheme.highContrastDark(),
    }.entries) {
      test('${entry.key}: every text step is >= 4.5:1', () {
        final theme = entry.value;
        final s = theme.extension<SaafTokens>()!;
        final bg = theme.colorScheme.surface;
        for (final (name, color) in [
          ('textLabel', s.textLabel),
          ('textSecondary', s.textSecondary),
          ('textCaption', s.textCaption),
          ('textMeta', s.textMeta),
          ('textOverline', s.textOverline),
          ('onSurface', theme.colorScheme.onSurface),
          ('onSurfaceVariant', theme.colorScheme.onSurfaceVariant),
        ]) {
          expect(
            contrast(color, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$name on surface',
          );
        }
      });
    }

    test('default theme keeps the Figma values (caption below 4.5:1)', () {
      final theme = SaafTheme.light();
      final s = theme.extension<SaafTokens>()!;
      expect(
        contrast(s.textOverline, theme.colorScheme.surface),
        lessThan(4.5),
      );
    });

    test('non-text tokens are unchanged by high contrast', () {
      final normal = SaafTheme.light().extension<SaafTokens>()!;
      final hc = SaafTheme.highContrastLight().extension<SaafTokens>()!;
      expect(hc.borderCard, normal.borderCard);
      expect(hc.sageTint, normal.sageTint);
    });
  });

  group('component defaults live in ThemeData (design.md §1)', () {
    final theme = SaafTheme.light();
    test('buttons are 56 dp tall pills with r28', () {
      final style = theme.filledButtonTheme.style!;
      expect(style.minimumSize?.resolve({}), const Size(0, 56));
      final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(28));
    });

    test('inputs use r14 and the 1 dp / 1.5 dp borders', () {
      final border =
          theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      final focused =
          theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(14));
      expect(border.borderSide.width, 1);
      expect(focused.borderSide.width, 1.5);
    });

    test('iOS gets Cupertino page transitions (swipe back)', () {
      final builders = theme.pageTransitionsTheme.builders;
      expect(
        builders[TargetPlatform.iOS],
        isA<CupertinoPageTransitionsBuilder>(),
      );
    });
  });

  group('breakpoints (design.md §7)', () {
    test('compact < 600 <= medium < 840 <= expanded', () {
      expect(SaafBreakpoint.fromWidth(320), SaafBreakpoint.compact);
      expect(SaafBreakpoint.fromWidth(599.9), SaafBreakpoint.compact);
      expect(SaafBreakpoint.fromWidth(600), SaafBreakpoint.medium);
      expect(SaafBreakpoint.fromWidth(839.9), SaafBreakpoint.medium);
      expect(SaafBreakpoint.fromWidth(840), SaafBreakpoint.expanded);
      expect(SaafBreakpoint.fromWidth(1280), SaafBreakpoint.expanded);
    });

    test('content max width is 560 and gutter shrinks below 360', () {
      expect(SaafBreakpoint.maxContentWidth, 560);
      expect(SaafBreakpoint.gutterFor(390), 20);
      expect(SaafBreakpoint.gutterFor(359), 16);
    });
  });

  testWidgets('context extension exposes colors, text and saaf tokens', (
    tester,
  ) async {
    late SaafTokens tokens;
    late ColorScheme colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: SaafTheme.light(),
        home: Builder(
          builder: (context) {
            tokens = context.saaf;
            colors = context.colors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(colors.primary, SaafPalette.sage);
    expect(tokens.space.gutter, 20);
  });
}
