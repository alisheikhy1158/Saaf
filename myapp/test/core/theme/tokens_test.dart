// Covers: design.md §2 (palette), §3 (type scale), §4 (spacing/radii/sizes) —
// Figma is the source of truth, this is the token snapshot test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';

void main() {
  group('palette (design.md §2.1)', () {
    test('matches the colours used on the Figma screens', () {
      expect(SaafPalette.cornsilk, const Color(0xFFFEFAE0));
      expect(SaafPalette.ink, const Color(0xFF3D3120));
      expect(SaafPalette.sage, const Color(0xFFCCD5AE));
      expect(SaafPalette.lightSage, const Color(0xFFE9EDC9));
      expect(SaafPalette.papaya, const Color(0xFFFAEDCD));
      expect(SaafPalette.tan, const Color(0xFFD4A373));
    });

    test('error colours are the build-time additions (§9.6)', () {
      expect(SaafPalette.errorLight, const Color(0xFFB3261E));
      expect(SaafPalette.errorDark, const Color(0xFFF2B8B5));
    });
  });

  group('ink-opacity ladder (design.md §2.2)', () {
    test('alphas equal the Figma values', () {
      expect(SaafAlpha.textLabel, 0.70);
      expect(SaafAlpha.textSecondary, 0.60);
      expect(SaafAlpha.textCaption, 0.55);
      expect(SaafAlpha.textMeta, 0.50);
      expect(SaafAlpha.textOverline, 0.45);
      expect(SaafAlpha.checkBorder, 0.25);
      expect(SaafAlpha.divider, 0.15);
      expect(SaafAlpha.borderStrong, 0.14);
      expect(SaafAlpha.borderControl, 0.12);
      expect(SaafAlpha.borderOption, 0.10);
      expect(SaafAlpha.borderCard, 0.09);
      expect(SaafAlpha.borderSubtle, 0.08);
      expect(SaafAlpha.rowDivider, 0.07);
      expect(SaafAlpha.trackSegmented, 0.04);
      expect(SaafAlpha.tint, 0.10);
    });
  });

  group('spacing (design.md §4)', () {
    const s = SaafSpace();
    test('raw scale', () {
      expect(
        [
          s.x2,
          s.x4,
          s.x6,
          s.x8,
          s.x10,
          s.x12,
          s.x14,
          s.x16,
          s.x18,
          s.x20,
          s.x22,
          s.x24,
          s.x28,
          s.x36,
        ],
        [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 36],
      );
    });

    test('semantic aliases', () {
      expect(s.gutter, 20);
      expect(s.gutterNarrow, 16);
      expect(s.pageBottom, 28);
      expect(s.topBarTop, 4);
      expect(s.topBarBottom, 12);
      expect(s.titleToSubtitle, 10);
      expect(s.inkCardPadding, 20);
      expect(s.groupPaddingH, 16);
      expect(s.settingsGroupPaddingV, 2);
      expect(s.checklistPaddingV, 4);
      expect(s.rowPaddingV, 12);
      expect(s.settingsRowPaddingV, 14);
      expect(s.rowGap, 12);
      expect(s.optionPadding, 14);
      expect(s.optionGap, 10);
      expect(s.planPaddingH, 18);
      expect(s.planPaddingV, 16);
      expect(s.benefitGap, 14);
      expect(s.chipPaddingH, 14);
      expect(s.chipPaddingV, 8);
      expect(s.chipIconGap, 6);
      expect(s.smallChipPaddingH, 10);
      expect(s.smallChipPaddingV, 4);
      expect(s.buttonPaddingH, 24);
      expect(s.buttonPaddingV, 18);
      expect(s.navPaddingH, 36);
    });
  });

  group('01 Welcome hero (Figma node 2:37)', () {
    test('design frame is 350 × 372', () {
      const g = SaafHeroGeometry();
      expect(g.designWidth, 350);
      expect(g.designHeight, 372);
    });

    test('decorative shapes sit where Figma puts them', () {
      const g = SaafHeroGeometry();
      expect(
        [g.bigCircleLeft, g.bigCircleTop, g.bigCircleSize],
        [120, 140, 320],
      );
      expect(
        [g.cornerCircleLeft, g.cornerCircleTop, g.cornerCircleSize],
        [-70, -60, 220],
      );
      expect(
        [g.ovalLeft, g.ovalTop, g.ovalWidth, g.ovalHeight],
        [91, 70, 168, 214],
      );
      expect(
        [g.glowLeft, g.glowTop, g.glowWidth, g.glowHeight],
        [77, 55, 196, 244],
      );
    });

    test('shape opacities equal the Figma fills', () {
      expect(SaafAlpha.heroLightCircle, closeTo(0.0784, 0.0001));
      expect(SaafAlpha.heroInkCircle, closeTo(0.1216, 0.0001));
      expect(SaafAlpha.heroOvalFill, closeTo(0.1020, 0.0001));
      expect(SaafAlpha.heroOvalStroke, 0.4);
    });
  });

  group('radii (design.md §4)', () {
    const r = SaafRadius();
    test('equal the Figma scale', () {
      expect(r.r3, 3);
      expect(r.r12, 12);
      expect(r.r14, 14);
      expect(r.r18, 18);
      expect(r.r20, 20);
      expect(r.r22, 22);
      expect(r.r24, 24);
      expect(r.r26, 26);
      expect(r.r28, 28);
      expect(r.r32, 32);
    });
  });

  group('sizes (design.md §4)', () {
    const z = SaafSize();
    test('equal the Figma values', () {
      expect(z.button, 56);
      expect(z.input, 56);
      expect(z.otpBoxWidth, 50);
      expect(z.otpBoxHeight, 58);
      expect(z.iconButton, 40);
      expect(z.iconCircle, 40);
      expect(z.iconCircleSmall, 36);
      expect(z.iconCircleWelcome, 38);
      expect(z.iconCircleLarge, 64);
      expect(z.avatar, 64);
      expect(z.thumbnail, 48);
      expect(z.check, 26);
      expect(z.checkMedium, 24);
      expect(z.checkSmall, 22);
      expect(z.checkIcon, 16);
      expect(z.checkIconMedium, 14);
      expect(z.checkIconSmall, 13);
      expect(z.dayWidth, 44);
      expect(z.dayHeight, 68);
      expect(z.dayDot, 5);
      expect(z.bottomNav, 64);
      expect(z.shutter, 78);
      expect(z.cameraControl, 48);
      expect(z.icon, 20);
      expect(z.iconSmall, 16);
      expect(z.iconChip, 14);
      expect(z.iconCamera, 22);
      expect(z.keypadIcon, 24);
      expect(z.progressBar, 6);
      expect(z.progressRing, 76);
      expect(z.borderThin, 1);
      expect(z.borderFocus, 1.5);
      expect(z.borderSelectedPlan, 2);
    });

    test('hit area is 48 dp (§9.1) while the visuals stay as Figma', () {
      expect(z.minTouchTarget, 48);
      expect(z.iconButton, lessThan(z.minTouchTarget));
    });
  });

  group('typography (design.md §3)', () {
    test('font families', () {
      expect(SaafType.fontFamily, 'Nunito');
      expect(SaafType.fallbackFamilies, ['NotoNaskhArabic']);
    });

    test('headline sizes and weights', () {
      expect(SaafType.display.fontSize, 46);
      expect(SaafType.display.fontWeight, FontWeight.w800);
      expect(SaafType.headlineLarge.fontSize, 34);
      expect(SaafType.headlineMedium.fontSize, 30);
      expect(SaafType.headlineSmall.fontSize, 29);
      expect(SaafType.titleLarge.fontSize, 24);
      expect(SaafType.titleMedium.fontSize, 18);
      expect(SaafType.sectionTitle.fontSize, 17);
    });

    test('line heights are line-height ÷ size', () {
      expect(SaafType.display.height, closeTo(48 / 46, 0.001));
      expect(SaafType.headlineLarge.height, closeTo(44 / 34, 0.001));
      expect(SaafType.button.height, closeTo(20 / 16, 0.001));
      expect(SaafType.subtitle.height, closeTo(22 / 15, 0.001));
      expect(SaafType.caption.height, closeTo(16 / 12, 0.001));
    });

    test('wordmark is 30 / 33 ExtraBold (01 "Saaf")', () {
      expect(SaafType.wordmark.fontSize, 30);
      expect(SaafType.wordmark.height, closeTo(1.1, 0.001));
      expect(SaafType.wordmark.fontWeight, FontWeight.w800);
    });

    test('body, button, chip, overline', () {
      expect(SaafType.button.fontSize, 16);
      expect(SaafType.button.fontWeight, FontWeight.w800);
      expect(SaafType.subtitle.fontSize, 15);
      expect(SaafType.subtitle.fontWeight, FontWeight.w400);
      expect(SaafType.body.fontSize, 14);
      expect(SaafType.chip.fontSize, 13);
      expect(SaafType.caption.fontSize, 12);
      expect(SaafType.overline.fontSize, 12);
      expect(SaafType.overline.letterSpacing, closeTo(0.96, 0.001));
      expect(SaafType.micro.fontSize, 11);
    });
  });

  group('motion (design.md §8)', () {
    test('durations', () {
      const m = SaafMotion();
      expect(m.fast, const Duration(milliseconds: 150));
      expect(m.medium, const Duration(milliseconds: 250));
      expect(m.slow, const Duration(milliseconds: 400));
      expect(m.curve, Curves.easeOutCubic);
    });
  });
}
