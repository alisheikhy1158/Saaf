import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/theme/tokens.dart';

/// Builds the four Saaf themes (design.md §1): light, dark and the two
/// high-contrast variants used when the OS asks for more contrast (§2.4).
/// Unified Material 3 styled exactly like Figma on both platforms (§5).
abstract final class SaafTheme {
  static ThemeData light() => _build(
    scheme: _lightScheme(highContrast: false),
    tokens: SaafTokens.light(),
  );

  static ThemeData dark() => _build(
    scheme: _darkScheme(highContrast: false),
    tokens: SaafTokens.dark(),
  );

  static ThemeData highContrastLight() => _build(
    scheme: _lightScheme(highContrast: true),
    tokens: SaafTokens.light(highContrast: true),
  );

  static ThemeData highContrastDark() => _build(
    scheme: _darkScheme(highContrast: true),
    tokens: SaafTokens.dark(highContrast: true),
  );

  static double _text(double alpha, bool highContrast) =>
      highContrast && alpha < SaafAlpha.highContrastTextFloor
      ? SaafAlpha.highContrastTextFloor
      : alpha;

  static ColorScheme _lightScheme({required bool highContrast}) {
    const ink = SaafPalette.ink;
    const cornsilk = SaafPalette.cornsilk;
    return ColorScheme(
      brightness: Brightness.light,
      primary: SaafPalette.sage,
      onPrimary: ink,
      primaryContainer: SaafPalette.lightSage,
      onPrimaryContainer: ink,
      secondary: SaafPalette.sage,
      onSecondary: ink,
      secondaryContainer: SaafPalette.papaya,
      onSecondaryContainer: ink,
      tertiary: SaafPalette.tan,
      onTertiary: ink,
      error: SaafPalette.errorLight,
      onError: cornsilk,
      surface: cornsilk,
      onSurface: ink,
      onSurfaceVariant: ink.withValues(
        alpha: _text(SaafAlpha.textSecondary, highContrast),
      ),
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: cornsilk,
      surfaceContainerLow: cornsilk,
      surfaceContainer: cornsilk,
      surfaceContainerHigh: cornsilk,
      surfaceContainerHighest: cornsilk,
      outline: ink.withValues(alpha: SaafAlpha.borderControl),
      outlineVariant: ink.withValues(alpha: SaafAlpha.rowDivider),
      inverseSurface: ink,
      onInverseSurface: cornsilk,
      inversePrimary: SaafPalette.sage,
      shadow: Colors.transparent,
      scrim: ink,
    );
  }

  static ColorScheme _darkScheme({required bool highContrast}) {
    const ink = SaafPalette.ink;
    const cornsilk = SaafPalette.cornsilk;
    Color onInk(double alpha) =>
        Color.alphaBlend(cornsilk.withValues(alpha: alpha), ink);
    return ColorScheme(
      brightness: Brightness.dark,
      primary: SaafPalette.sage,
      onPrimary: ink,
      primaryContainer: onInk(SaafAlpha.borderControl),
      onPrimaryContainer: cornsilk,
      secondary: SaafPalette.sage,
      onSecondary: ink,
      secondaryContainer: SaafPalette.papaya,
      onSecondaryContainer: ink,
      tertiary: SaafPalette.tan,
      onTertiary: ink,
      error: SaafPalette.errorDark,
      onError: ink,
      surface: ink,
      onSurface: cornsilk,
      onSurfaceVariant: cornsilk.withValues(alpha: SaafAlpha.textLabel),
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: ink,
      surfaceContainerLow: onInk(SaafAlpha.trackSegmentedDark),
      surfaceContainer: onInk(SaafAlpha.trackSegmentedDark),
      surfaceContainerHigh: onInk(SaafAlpha.borderControl),
      surfaceContainerHighest: onInk(SaafAlpha.borderControl),
      outline: cornsilk.withValues(alpha: SaafAlpha.borderControl),
      outlineVariant: cornsilk.withValues(alpha: SaafAlpha.rowDivider),
      inverseSurface: onInk(SaafAlpha.trackSegmentedDark + 0.03),
      onInverseSurface: cornsilk,
      inversePrimary: SaafPalette.sage,
      shadow: Colors.transparent,
      scrim: ink,
    );
  }

  static TextStyle _style(TextStyle base, Color color) => base.copyWith(
    color: color,
    fontFamily: SaafType.fontFamily,
    fontFamilyFallback: SaafType.fallbackFamilies,
  );

  static TextTheme _textTheme(ColorScheme scheme, SaafTokens tokens) {
    final primary = scheme.onSurface;
    return TextTheme(
      displaySmall: _style(SaafType.display, primary),
      headlineLarge: _style(SaafType.headlineLarge, primary),
      headlineMedium: _style(SaafType.headlineMedium, primary),
      headlineSmall: _style(SaafType.headlineSmall, primary),
      titleLarge: _style(SaafType.titleLarge, primary),
      titleMedium: _style(SaafType.titleMedium, primary),
      titleSmall: _style(SaafType.sectionTitle, primary),
      labelLarge: _style(SaafType.button, primary),
      labelMedium: _style(SaafType.chip, primary),
      labelSmall: _style(SaafType.overline, tokens.textOverline),
      bodyLarge: _style(SaafType.subtitle, primary),
      bodyMedium: _style(SaafType.body, primary),
      bodySmall: _style(SaafType.caption, tokens.textCaption),
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required SaafTokens tokens,
  }) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = _textTheme(scheme, tokens);
    final space = tokens.space;
    final radius = tokens.radius;
    final size = tokens.size;

    RoundedRectangleBorder rounded(
      double r, {
      BorderSide side = BorderSide.none,
    }) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: side,
    );

    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r14),
          borderSide: BorderSide(color: color, width: width),
        );

    final buttonPadding = EdgeInsetsDirectional.symmetric(
      horizontal: space.buttonPaddingH,
      vertical: space.buttonPaddingV,
    );
    final buttonShape = rounded(radius.r28);
    final onInk = isDark ? scheme.onSurface : SaafPalette.cornsilk;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      fontFamily: SaafType.fontFamily,
      fontFamilyFallback: SaafType.fallbackFamilies,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashColor: isDark
          ? SaafPalette.cornsilk.withValues(alpha: SaafAlpha.borderControl)
          : SaafPalette.ink.withValues(alpha: SaafAlpha.borderSubtle),
      highlightColor: Colors.transparent,
      iconTheme: IconThemeData(color: scheme.onSurface, size: size.icon),
      dividerTheme: DividerThemeData(
        color: tokens.rowDivider,
        thickness: size.borderThin,
        space: size.borderThin,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.5),
          minimumSize: Size(0, size.button),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.5),
          minimumSize: Size(0, size.button),
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: scheme.onSurface, width: size.borderFocus),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: Size(0, size.minTouchTarget),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.buttonPaddingH,
            vertical: space.textButtonPaddingV,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          fixedSize: Size.square(size.iconButton),
          minimumSize: Size.square(size.iconButton),
          padding: EdgeInsets.zero,
          iconSize: size.icon,
          tapTargetSize: MaterialTapTargetSize.padded,
          side: isDark
              ? BorderSide.none
              : BorderSide(color: tokens.borderControl, width: size.borderThin),
          backgroundColor: isDark ? tokens.borderControl : Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints(minHeight: size.input),
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: space.x16,
          vertical: space.x16,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: tokens.textMeta),
        labelStyle: tokens.styles.fieldLabel,
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        enabledBorder: inputBorder(tokens.borderControl, size.borderThin),
        border: inputBorder(tokens.borderControl, size.borderThin),
        disabledBorder: inputBorder(tokens.borderSubtle, size.borderThin),
        focusedBorder: inputBorder(tokens.borderFocus, size.borderFocus),
        errorBorder: inputBorder(scheme.error, size.borderThin),
        focusedErrorBorder: inputBorder(scheme.error, size.borderFocus),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        labelStyle: textTheme.labelMedium,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: space.chipPaddingH,
          vertical: space.chipPaddingV,
        ),
        shape: rounded(radius.r18),
        side: BorderSide.none,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded(
          radius.r20,
          side: BorderSide(color: tokens.borderCard, width: size.borderThin),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: tokens.checkBorder, width: size.borderFocus),
        shape: const CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: rounded(radius.r24),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius.r28)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: tokens.borderSubtle,
        linearMinHeight: size.progressBar,
        borderRadius: BorderRadius.circular(radius.r3),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.inverseSurface,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(
          color: scheme.primary,
          size: size.keypadIcon,
        ),
        unselectedIconTheme: IconThemeData(
          color: onInk.withValues(alpha: SaafAlpha.textSecondary),
          size: size.keypadIcon,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: onInk.withValues(alpha: SaafAlpha.textSecondary),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: rounded(radius.r14),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
