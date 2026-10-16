import 'package:flutter/material.dart';

/// Raw Figma values. This is the ONLY file allowed to contain hex codes and
/// numeric design literals (docs/design.md §1). Everything else reads these
/// through `ThemeData` / `SaafTokens`.

/// Colours used on the 14 Figma screens (design.md §2.1) plus the build-time
/// error colours (§9.6).
abstract final class SaafPalette {
  static const Color cornsilk = Color(0xFFFEFAE0);
  static const Color ink = Color(0xFF3D3120);
  static const Color sage = Color(0xFFCCD5AE);
  static const Color lightSage = Color(0xFFE9EDC9);
  static const Color papaya = Color(0xFFFAEDCD);
  static const Color tan = Color(0xFFD4A373);
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFF2B8B5);
}

/// Opacity ladder (design.md §2.2). Figma uses ink (or cornsilk on dark) with
/// alpha instead of grey hex codes.
abstract final class SaafAlpha {
  static const double textLabel = 0.70;
  static const double textSecondary = 0.60;
  static const double textCaption = 0.55;
  static const double textMeta = 0.50;
  static const double textOverline = 0.45;
  static const double checkBorder = 0.25;
  static const double divider = 0.15;
  static const double borderStrong = 0.14;
  static const double borderControl = 0.12;
  static const double borderOption = 0.10;
  static const double borderCard = 0.09;
  static const double borderSubtle = 0.08;
  static const double rowDivider = 0.07;
  static const double trackSegmented = 0.04;
  static const double trackSegmentedDark = 0.05;
  static const double tint = 0.10;
  static const double inkTint = 0.05;

  // 01 Welcome hero art (Figma node 2:37).
  static const double heroLightCircle = 0.0784;
  static const double heroInkCircle = 0.1216;
  static const double heroOvalFill = 0.1020;
  static const double heroOvalStroke = 0.4;

  /// Floor applied to every text step by the high-contrast themes (§2.4).
  static const double highContrastTextFloor = 0.70;
}

/// Spacing scale (design.md §4, Figma scale replaces the 8-pt grid).
class SaafSpace {
  const SaafSpace();

  // Raw scale — every value that appears in the Figma screens.
  final double x2 = 2;
  final double x4 = 4;
  final double x6 = 6;
  final double x8 = 8;
  final double x10 = 10;
  final double x12 = 12;
  final double x14 = 14;
  final double x16 = 16;
  final double x18 = 18;
  final double x20 = 20;
  final double x22 = 22;
  final double x24 = 24;
  final double x28 = 28;
  final double x36 = 36;

  // Semantic aliases.
  final double gutter = 20;
  final double gutterNarrow = 16;
  final double pageBottom = 28;
  final double topBarTop = 4;
  final double topBarBottom = 12;
  final double titleToSubtitle = 10;
  final double sectionGapSmall = 20;
  final double sectionGapMedium = 22;
  final double sectionGapLarge = 24;
  final double inkCardPadding = 20;
  final double groupPaddingH = 16;
  final double settingsGroupPaddingV = 2;
  final double checklistPaddingV = 4;
  final double rowPaddingV = 12;
  final double settingsRowPaddingV = 14;
  final double rowGap = 12;
  final double optionPadding = 14;
  final double optionGap = 10;
  final double planPaddingH = 18;
  final double planPaddingV = 16;
  final double benefitGap = 14;
  final double chipPaddingH = 14;
  final double chipPaddingV = 8;
  final double chipIconGap = 6;
  final double smallChipPaddingH = 10;
  final double smallChipPaddingV = 4;
  final double buttonPaddingH = 24;
  final double buttonPaddingV = 18;
  final double textButtonPaddingV = 10;
  final double navPaddingH = 36;
}

/// Geometry of the 01 Welcome hero (Figma node 2:37), in the 350 × 372 design
/// frame. The hero scales uniformly with its width.
class SaafHeroGeometry {
  const SaafHeroGeometry();

  final double designWidth = 350;
  final double designHeight = 372;

  final double bigCircleLeft = 120;
  final double bigCircleTop = 140;
  final double bigCircleSize = 320;

  final double cornerCircleLeft = -70;
  final double cornerCircleTop = -60;
  final double cornerCircleSize = 220;

  final double ovalLeft = 91;
  final double ovalTop = 70;
  final double ovalWidth = 168;
  final double ovalHeight = 214;

  final double glowLeft = 77;
  final double glowTop = 55;
  final double glowWidth = 196;
  final double glowHeight = 244;
}

/// Geometry of the 06 viewfinder (Figma node 3:57), in the 350 × 440 design
/// frame. The viewfinder scales with its box; [reservedHeight] is the height of
/// everything else on the screen (top bar, steps, chips, controls) at normal
/// text size, used to give the viewfinder the space that is left.
class SaafScanGeometry {
  const SaafScanGeometry();

  final double designWidth = 350;
  final double designHeight = 440;

  /// The oval the face should fill (dashed guide).
  final Rect guide = const Rect.fromLTWH(57, 62, 236, 306);

  /// The oval the progress arc runs along, just outside the guide.
  final Rect arc = const Rect.fromLTWH(47, 52, 256, 326);

  final double guideStroke = 2;
  final double arcStroke = 4;
  final double dashLength = 6;
  final double dashGap = 5;

  /// Where the arc starts: straight up (−90°).
  final double arcStartAngle = -1.5707963267948966;

  final double reservedHeight = 400;
  final double minHeight = 160;
}

/// Corner radii (design.md §4).
class SaafRadius {
  const SaafRadius();

  final double r3 = 3;
  final double r4 = 4;
  final double r7 = 7;
  final double r12 = 12;
  final double r14 = 14;
  final double r18 = 18;
  final double r20 = 20;
  final double r22 = 22;
  final double r24 = 24;
  final double r26 = 26;
  final double r28 = 28;
  final double r32 = 32;
}

/// Component sizes (design.md §4).
class SaafSize {
  const SaafSize();

  final double button = 56;
  final double input = 56;
  final double otpBoxWidth = 50;
  final double otpBoxHeight = 58;
  final double iconButton = 40;
  final double iconCircle = 40;
  final double iconCircleSmall = 36;
  final double iconCircleWelcome = 38;
  final double iconCircleLarge = 64;
  final double avatar = 64;
  final double thumbnail = 48;
  final double check = 26;
  final double checkMedium = 24;
  final double checkSmall = 22;
  final double checkIcon = 16;
  final double checkIconMedium = 14;
  final double checkIconSmall = 13;
  final double dayWidth = 44;
  final double dayHeight = 68;
  final double dayDot = 5;
  final double bottomNav = 64;
  final double shutter = 78;
  final double shutterRing = 4;
  final double shutterGap = 6;
  final double cameraControl = 48;
  final double icon = 20;
  final double iconSmall = 16;
  final double iconChip = 14;
  final double iconCamera = 22;
  final double keypadIcon = 24;
  final double progressBar = 6;
  final double progressBarThick = 8;
  final double scoreRing = 104;
  final double scoreRingStroke = 8;
  final double progressRing = 76;
  final double borderThin = 1;
  final double borderFocus = 1.5;
  final double borderSelectedPlan = 2;
  final double phoneDividerWidth = 1;
  final double phoneDividerHeight = 24;
  final double caretWidth = 2;
  final double caretHeight = 24;

  /// Hit area, NOT a visual size (design.md §9.1).
  final double minTouchTarget = 48;
}

/// Motion (design.md §8).
class SaafMotion {
  const SaafMotion();

  final Duration fast = const Duration(milliseconds: 150);
  final Duration medium = const Duration(milliseconds: 250);
  final Duration slow = const Duration(milliseconds: 400);
  final Curve curve = Curves.easeOutCubic;
}

/// Type scale (design.md §3). Line heights are given as line-height ÷ size.
/// Colour is applied by the theme, never here.
abstract final class SaafType {
  static const String fontFamily = 'Nunito';
  static const List<String> fallbackFamilies = ['NotoNaskhArabic'];

  static const TextStyle display = TextStyle(
    fontSize: 46,
    height: 48 / 46,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 34,
    height: 44 / 34,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 30,
    height: 40 / 30,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 29,
    height: 38 / 29,
    fontWeight: FontWeight.w800,
  );

  /// 04 Privacy consent title. design.md listed 34 / 44, but the Figma screen
  /// is 32 / 42 and Figma wins (design.md §0).
  static const TextStyle screenTitle = TextStyle(
    fontSize: 32,
    height: 42 / 32,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle checkLabel = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle pointCaption = TextStyle(
    fontSize: 13,
    height: 19 / 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle wordmark = TextStyle(
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle avatarInitial = TextStyle(
    fontSize: 27,
    height: 34 / 27,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle ringValue = TextStyle(
    fontSize: 21,
    height: 24 / 21,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle otpDigit = TextStyle(
    fontSize: 22,
    height: 1.4,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle keypadKey = TextStyle(
    fontSize: 24,
    height: 1,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle listTitle = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle rowTitle = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle segment = TextStyle(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle skip = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle chip = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle meta = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle legal = TextStyle(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w800,
    letterSpacing: 12 * 0.08,
  );

  /// 07 score ring value ("76").
  static const TextStyle scoreValue = TextStyle(
    fontSize: 29,
    height: 33 / 29,
    fontWeight: FontWeight.w800,
  );

  /// 07 "Skin score" caption under the ring value.
  static const TextStyle scoreLabel = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
  );

  /// 07 score-card headline ("Good base, two things to work on").
  static const TextStyle cardHeadline = TextStyle(
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w800,
  );
}
