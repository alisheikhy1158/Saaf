import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saaf/core/theme/tokens.dart';

/// Text styles that have no `TextTheme` slot (design.md §3), with the colour
/// from the Figma ladder already applied.
@immutable
class SaafTextStyles {
  const SaafTextStyles({
    required this.inputText,
    required this.listTitle,
    required this.rowTitle,
    required this.segment,
    required this.skip,
    required this.fieldLabel,
    required this.meta,
    required this.legal,
    required this.micro,
    required this.wordmark,
    required this.screenTitle,
    required this.checkLabel,
    required this.pointCaption,
    required this.avatarInitial,
    required this.ringValue,
    required this.scoreValue,
    required this.scoreLabel,
    required this.cardHeadline,
    required this.otpDigit,
    required this.keypadKey,
  });

  final TextStyle inputText;
  final TextStyle listTitle;
  final TextStyle rowTitle;
  final TextStyle segment;
  final TextStyle skip;
  final TextStyle fieldLabel;
  final TextStyle meta;
  final TextStyle legal;
  final TextStyle micro;
  final TextStyle wordmark;
  final TextStyle screenTitle;
  final TextStyle checkLabel;
  final TextStyle pointCaption;
  final TextStyle avatarInitial;
  final TextStyle ringValue;
  final TextStyle scoreValue;
  final TextStyle scoreLabel;
  final TextStyle cardHeadline;
  final TextStyle otpDigit;
  final TextStyle keypadKey;

  static TextStyle _style(TextStyle base, Color color) => base.copyWith(
    color: color,
    fontFamily: SaafType.fontFamily,
    fontFamilyFallback: SaafType.fallbackFamilies,
  );

  factory SaafTextStyles.build({
    required Color primary,
    required Color label,
    required Color metaColor,
    required Color secondary,
  }) {
    return SaafTextStyles(
      inputText: _style(SaafType.inputText, primary),
      listTitle: _style(SaafType.listTitle, primary),
      rowTitle: _style(SaafType.rowTitle, primary),
      segment: _style(SaafType.segment, primary),
      skip: _style(SaafType.skip, primary),
      fieldLabel: _style(SaafType.fieldLabel, label),
      meta: _style(SaafType.meta, metaColor),
      legal: _style(SaafType.legal, metaColor),
      micro: _style(SaafType.micro, metaColor),
      wordmark: _style(SaafType.wordmark, primary),
      screenTitle: _style(SaafType.screenTitle, primary),
      checkLabel: _style(SaafType.checkLabel, primary),
      pointCaption: _style(SaafType.pointCaption, secondary),
      avatarInitial: _style(SaafType.avatarInitial, primary),
      ringValue: _style(SaafType.ringValue, primary),
      scoreValue: _style(SaafType.scoreValue, primary),
      scoreLabel: _style(SaafType.scoreLabel, primary),
      cardHeadline: _style(SaafType.cardHeadline, primary),
      otpDigit: _style(SaafType.otpDigit, primary),
      keypadKey: _style(SaafType.keypadKey, primary),
    );
  }

  SaafTextStyles lerp(SaafTextStyles other, double t) {
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return SaafTextStyles(
      inputText: l(inputText, other.inputText),
      listTitle: l(listTitle, other.listTitle),
      rowTitle: l(rowTitle, other.rowTitle),
      segment: l(segment, other.segment),
      skip: l(skip, other.skip),
      fieldLabel: l(fieldLabel, other.fieldLabel),
      meta: l(meta, other.meta),
      legal: l(legal, other.legal),
      micro: l(micro, other.micro),
      wordmark: l(wordmark, other.wordmark),
      screenTitle: l(screenTitle, other.screenTitle),
      checkLabel: l(checkLabel, other.checkLabel),
      pointCaption: l(pointCaption, other.pointCaption),
      avatarInitial: l(avatarInitial, other.avatarInitial),
      ringValue: l(ringValue, other.ringValue),
      scoreValue: l(scoreValue, other.scoreValue),
      scoreLabel: l(scoreLabel, other.scoreLabel),
      cardHeadline: l(cardHeadline, other.cardHeadline),
      otpDigit: l(otpDigit, other.otpDigit),
      keypadKey: l(keypadKey, other.keypadKey),
    );
  }
}

/// Brand colours with no `ColorScheme` slot, the ink-opacity ladder, spacing,
/// radii, sizes and motion (design.md §1, §2.2, §4, §8).
@immutable
class SaafTokens extends ThemeExtension<SaafTokens> {
  const SaafTokens({
    required this.sage,
    required this.lightSage,
    required this.papaya,
    required this.tan,
    required this.textLabel,
    required this.textSecondary,
    required this.textCaption,
    required this.textMeta,
    required this.textOverline,
    required this.checkBorder,
    required this.divider,
    required this.borderStrong,
    required this.borderControl,
    required this.borderOption,
    required this.borderCard,
    required this.borderSubtle,
    required this.rowDivider,
    required this.trackSegmented,
    required this.sageTint,
    required this.papayaTint,
    required this.borderFocus,
    required this.trackOnInk,
    required this.controlOnInk,
    required this.onInkLabel,
    required this.onInkSecondary,
    required this.onInkMeta,
    required this.styles,
    required this.inkTint,
    this.space = const SaafSpace(),
    this.radius = const SaafRadius(),
    this.size = const SaafSize(),
    this.motion = const SaafMotion(),
    this.scan = const SaafScanGeometry(),
    this.thumbnail = const SaafThumbnailGeometry(),
  });

  /// Light theme tokens: ink drawn at the Figma alphas on cornsilk.
  /// With [highContrast], every text step below 0.70 is raised to 0.70 (§2.4).
  factory SaafTokens.light({bool highContrast = false}) => _build(
    ink: SaafPalette.ink,
    onInk: SaafPalette.cornsilk,
    highContrast: highContrast,
    segmentedAlpha: SaafAlpha.trackSegmented,
    borderCardAlpha: SaafAlpha.borderCard,
  );

  /// Dark theme tokens: cornsilk drawn at the same alphas on ink (§2.3).
  factory SaafTokens.dark({bool highContrast = false}) => _build(
    ink: SaafPalette.cornsilk,
    onInk: SaafPalette.cornsilk,
    highContrast: highContrast,
    segmentedAlpha: SaafAlpha.trackSegmentedDark,
    borderCardAlpha: SaafAlpha.borderControl,
  );

  static SaafTokens _build({
    required Color ink,
    required Color onInk,
    required bool highContrast,
    required double segmentedAlpha,
    required double borderCardAlpha,
  }) {
    Color a(Color c, double alpha) => c.withValues(alpha: alpha);
    double text(double alpha) =>
        highContrast ? math.max(alpha, SaafAlpha.highContrastTextFloor) : alpha;

    final textLabel = a(ink, text(SaafAlpha.textLabel));
    final textMeta = a(ink, text(SaafAlpha.textMeta));
    return SaafTokens(
      sage: SaafPalette.sage,
      lightSage: SaafPalette.lightSage,
      papaya: SaafPalette.papaya,
      tan: SaafPalette.tan,
      textLabel: textLabel,
      textSecondary: a(ink, text(SaafAlpha.textSecondary)),
      textCaption: a(ink, text(SaafAlpha.textCaption)),
      textMeta: textMeta,
      textOverline: a(ink, text(SaafAlpha.textOverline)),
      checkBorder: a(ink, SaafAlpha.checkBorder),
      divider: a(ink, SaafAlpha.divider),
      borderStrong: a(ink, SaafAlpha.borderStrong),
      borderControl: a(ink, SaafAlpha.borderControl),
      borderOption: a(ink, SaafAlpha.borderOption),
      borderCard: a(ink, borderCardAlpha),
      borderSubtle: a(ink, SaafAlpha.borderSubtle),
      rowDivider: a(ink, SaafAlpha.rowDivider),
      trackSegmented: a(ink, segmentedAlpha),
      sageTint: a(SaafPalette.sage, SaafAlpha.tint),
      papayaTint: a(SaafPalette.papaya, SaafAlpha.tint),
      borderFocus: ink,
      trackOnInk: a(onInk, SaafAlpha.divider),
      controlOnInk: a(onInk, SaafAlpha.borderControl),
      onInkLabel: a(onInk, text(SaafAlpha.textLabel)),
      onInkSecondary: a(onInk, text(SaafAlpha.textSecondary)),
      onInkMeta: a(onInk, text(SaafAlpha.textMeta)),
      styles: SaafTextStyles.build(
        primary: ink,
        label: textLabel,
        metaColor: textMeta,
        secondary: a(ink, text(SaafAlpha.textSecondary)),
      ),
      inkTint: a(ink, SaafAlpha.inkTint),
    );
  }

  // Brand colours.
  final Color sage;
  final Color lightSage;
  final Color papaya;
  final Color tan;

  // Text ladder on the page background.
  final Color textLabel;
  final Color textSecondary;
  final Color textCaption;
  final Color textMeta;
  final Color textOverline;

  // Borders, dividers, tracks and tints.
  final Color checkBorder;
  final Color divider;
  final Color borderStrong;
  final Color borderControl;
  final Color borderOption;
  final Color borderCard;
  final Color borderSubtle;
  final Color rowDivider;
  final Color trackSegmented;
  final Color sageTint;
  final Color papayaTint;
  final Color borderFocus;

  // Ink cards (09 progress, 07 score, 14 promo): cornsilk text ladder.
  final Color trackOnInk;
  final Color controlOnInk;
  final Color onInkLabel;
  final Color onInkSecondary;
  final Color onInkMeta;

  final SaafTextStyles styles;

  /// The page ink at 5 % (04 point icon circles).
  final Color inkTint;
  final SaafSpace space;
  final SaafRadius radius;
  final SaafSize size;
  final SaafMotion motion;
  final SaafScanGeometry scan;
  final SaafThumbnailGeometry thumbnail;

  @override
  SaafTokens copyWith({
    Color? sage,
    Color? lightSage,
    Color? papaya,
    Color? tan,
    Color? textLabel,
    Color? textSecondary,
    Color? textCaption,
    Color? textMeta,
    Color? textOverline,
    Color? checkBorder,
    Color? divider,
    Color? borderStrong,
    Color? borderControl,
    Color? borderOption,
    Color? borderCard,
    Color? borderSubtle,
    Color? rowDivider,
    Color? trackSegmented,
    Color? sageTint,
    Color? papayaTint,
    Color? borderFocus,
    Color? trackOnInk,
    Color? controlOnInk,
    Color? onInkLabel,
    Color? onInkSecondary,
    Color? onInkMeta,
    SaafTextStyles? styles,
    Color? inkTint,
  }) {
    return SaafTokens(
      sage: sage ?? this.sage,
      lightSage: lightSage ?? this.lightSage,
      papaya: papaya ?? this.papaya,
      tan: tan ?? this.tan,
      textLabel: textLabel ?? this.textLabel,
      textSecondary: textSecondary ?? this.textSecondary,
      textCaption: textCaption ?? this.textCaption,
      textMeta: textMeta ?? this.textMeta,
      textOverline: textOverline ?? this.textOverline,
      checkBorder: checkBorder ?? this.checkBorder,
      divider: divider ?? this.divider,
      borderStrong: borderStrong ?? this.borderStrong,
      borderControl: borderControl ?? this.borderControl,
      borderOption: borderOption ?? this.borderOption,
      borderCard: borderCard ?? this.borderCard,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      rowDivider: rowDivider ?? this.rowDivider,
      trackSegmented: trackSegmented ?? this.trackSegmented,
      sageTint: sageTint ?? this.sageTint,
      papayaTint: papayaTint ?? this.papayaTint,
      borderFocus: borderFocus ?? this.borderFocus,
      trackOnInk: trackOnInk ?? this.trackOnInk,
      controlOnInk: controlOnInk ?? this.controlOnInk,
      onInkLabel: onInkLabel ?? this.onInkLabel,
      onInkSecondary: onInkSecondary ?? this.onInkSecondary,
      onInkMeta: onInkMeta ?? this.onInkMeta,
      styles: styles ?? this.styles,
      inkTint: inkTint ?? this.inkTint,
      space: space,
      radius: radius,
      size: size,
      motion: motion,
      scan: scan,
      thumbnail: thumbnail,
    );
  }

  @override
  SaafTokens lerp(ThemeExtension<SaafTokens>? other, double t) {
    if (other is! SaafTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SaafTokens(
      sage: l(sage, other.sage),
      lightSage: l(lightSage, other.lightSage),
      papaya: l(papaya, other.papaya),
      tan: l(tan, other.tan),
      textLabel: l(textLabel, other.textLabel),
      textSecondary: l(textSecondary, other.textSecondary),
      textCaption: l(textCaption, other.textCaption),
      textMeta: l(textMeta, other.textMeta),
      textOverline: l(textOverline, other.textOverline),
      checkBorder: l(checkBorder, other.checkBorder),
      divider: l(divider, other.divider),
      borderStrong: l(borderStrong, other.borderStrong),
      borderControl: l(borderControl, other.borderControl),
      borderOption: l(borderOption, other.borderOption),
      borderCard: l(borderCard, other.borderCard),
      borderSubtle: l(borderSubtle, other.borderSubtle),
      rowDivider: l(rowDivider, other.rowDivider),
      trackSegmented: l(trackSegmented, other.trackSegmented),
      sageTint: l(sageTint, other.sageTint),
      papayaTint: l(papayaTint, other.papayaTint),
      borderFocus: l(borderFocus, other.borderFocus),
      trackOnInk: l(trackOnInk, other.trackOnInk),
      controlOnInk: l(controlOnInk, other.controlOnInk),
      onInkLabel: l(onInkLabel, other.onInkLabel),
      onInkSecondary: l(onInkSecondary, other.onInkSecondary),
      onInkMeta: l(onInkMeta, other.onInkMeta),
      styles: styles.lerp(other.styles, t),
      inkTint: l(inkTint, other.inkTint),
      space: space,
      radius: radius,
      size: size,
      motion: motion,
      scan: scan,
      thumbnail: thumbnail,
    );
  }
}

/// `context.colors`, `context.text`, `context.saaf` (design.md §1).
extension SaafContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  SaafTokens get saaf => Theme.of(this).extension<SaafTokens>()!;
}
