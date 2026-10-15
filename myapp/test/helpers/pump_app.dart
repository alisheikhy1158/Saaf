// Shared widget-test harness (tests/test-strategy.md §4).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_theme.dart';

/// The responsive matrix from design.md §7 / test-strategy.md §4.
const List<Size> matrixSizes = [
  Size(320, 568), // small phone / flip cover
  Size(390, 844), // phone (Figma frame)
  Size(768, 1024), // iPad portrait
  Size(1280, 800), // tablet landscape / unfolded
];

/// Pumps [child] inside ProviderScope + MaterialApp with the Saaf themes and
/// localisation. Pass `scaffold: false` when [child] is itself a Scaffold.
Future<void> pumpSaaf(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(390, 844),
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  bool highContrast = false,
  TargetPlatform? platform,
  bool scaffold = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(highContrast: highContrast);
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    debugDefaultTargetPlatformOverride = null;
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: SaafTheme.light(),
        darkTheme: SaafTheme.dark(),
        highContrastTheme: SaafTheme.highContrastLight(),
        highContrastDarkTheme: SaafTheme.highContrastDark(),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: scaffold ? Scaffold(body: child) : child,
      ),
    ),
  );
  await tester.pump();
}

/// Renders [build] at every size of the matrix, in dark mode, at 200 % text
/// scale, in Urdu (RTL) and with high contrast, failing on any exception
/// (e.g. RenderFlex overflow).
Future<void> expectRobustLayout(
  WidgetTester tester,
  Widget Function() build, {
  bool scaffold = true,
}) async {
  for (final size in matrixSizes) {
    await pumpSaaf(tester, build(), size: size, scaffold: scaffold);
    expect(tester.takeException(), isNull, reason: 'light at $size');
  }
  await pumpSaaf(
    tester,
    build(),
    themeMode: ThemeMode.dark,
    scaffold: scaffold,
  );
  expect(tester.takeException(), isNull, reason: 'dark');

  await pumpSaaf(tester, build(), textScale: 2.0, scaffold: scaffold);
  expect(tester.takeException(), isNull, reason: 'text scale 2.0');

  await pumpSaaf(
    tester,
    build(),
    locale: const Locale('ur'),
    scaffold: scaffold,
  );
  expect(tester.takeException(), isNull, reason: 'Urdu RTL');

  await pumpSaaf(tester, build(), highContrast: true, scaffold: scaffold);
  expect(tester.takeException(), isNull, reason: 'high contrast');
}

/// Runs the three tap-target / label guidelines (test-strategy.md §4.3).
Future<void> expectTapTargetsAccessible(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  handle.dispose();
}
