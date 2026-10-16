// Shared widget-test harness (tests/test-strategy.md §4).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/app_router.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/data/services/web/fake_notification_permission_service.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';
import 'package:saaf/presentation/providers/app_router_provider.dart';
import 'package:saaf/presentation/providers/notification_providers.dart';

/// The responsive matrix from design.md §7 / test-strategy.md §4.
const List<Size> matrixSizes = [
  Size(320, 568), // small phone / flip cover
  Size(390, 844), // phone (Figma frame)
  Size(768, 1024), // iPad portrait
  Size(1280, 800), // tablet landscape / unfolded
];

/// No test talks to a real phone: notifications are pretend, with a permission
/// nobody has asked for yet, unless a test passes its own fakes.
List<Override> _phoneFakes(
  NotificationPermissionService? permissions,
  ReminderScheduler? scheduler,
) => [
  notificationPermissionServiceProvider.overrideWithValue(
    permissions ??
        FakeNotificationPermissionService(NotificationPermission.denied),
  ),
  reminderSchedulerProvider.overrideWithValue(
    scheduler ?? FakeReminderScheduler(),
  ),
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
  NotificationPermissionService? permissions,
  ReminderScheduler? scheduler,
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
      overrides: [..._phoneFakes(permissions, scheduler), ...overrides],
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

/// Pumps the real [SaafApp] (router, theme, locale) starting at [location].
/// Uses fixed-duration pumps: a spinner anywhere would hang `pumpAndSettle`.
Future<void> pumpSaafApp(
  WidgetTester tester, {
  String location = '/welcome',
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
  NotificationPermissionService? permissions,
  ReminderScheduler? scheduler,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ..._phoneFakes(permissions, scheduler),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: location),
        ),
        ...overrides,
      ],
      child: const SaafApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Renders [build] at every size of the matrix, in dark mode, at 200 % text
/// scale, in Urdu (RTL) and with high contrast, failing on any exception
/// (e.g. RenderFlex overflow).
Future<void> expectRobustLayout(
  WidgetTester tester,
  Widget Function() build, {
  bool scaffold = true,
  List<Override> overrides = const [],
}) async {
  for (final size in matrixSizes) {
    await pumpSaaf(
      tester,
      build(),
      size: size,
      scaffold: scaffold,
      overrides: overrides,
    );
    expect(tester.takeException(), isNull, reason: 'light at $size');
  }
  await pumpSaaf(
    tester,
    build(),
    themeMode: ThemeMode.dark,
    scaffold: scaffold,
    overrides: overrides,
  );
  expect(tester.takeException(), isNull, reason: 'dark');

  await pumpSaaf(
    tester,
    build(),
    textScale: 2.0,
    scaffold: scaffold,
    overrides: overrides,
  );
  expect(tester.takeException(), isNull, reason: 'text scale 2.0');

  await pumpSaaf(
    tester,
    build(),
    locale: const Locale('ur'),
    scaffold: scaffold,
    overrides: overrides,
  );
  expect(tester.takeException(), isNull, reason: 'Urdu RTL');

  await pumpSaaf(
    tester,
    build(),
    highContrast: true,
    scaffold: scaffold,
    overrides: overrides,
  );
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

/// Like [expectRobustLayout] for screens that load something first (a provider
/// future, a camera): each configuration starts from a fresh screen and gets
/// [settlePumps] frames to reach its real content, and [after] can move it on
/// (e.g. tap a button) before the overflow check.
Future<void> expectRobustLayoutSettled(
  WidgetTester tester,
  Widget Function() build, {
  bool scaffold = true,
  List<Override> overrides = const [],
  int settlePumps = 2,
  Future<void> Function()? after,
}) async {
  final configs = <(String, Size, ThemeMode, double, Locale, bool)>[
    for (final size in matrixSizes)
      ('$size', size, ThemeMode.light, 1, const Locale('en'), false),
    ('dark', matrixSizes[1], ThemeMode.dark, 1, const Locale('en'), false),
    (
      'text scale 2.0',
      matrixSizes[1],
      ThemeMode.light,
      2,
      const Locale('en'),
      false,
    ),
    ('Urdu RTL', matrixSizes[1], ThemeMode.light, 1, const Locale('ur'), false),
    (
      'high contrast',
      matrixSizes[1],
      ThemeMode.light,
      1,
      const Locale('en'),
      true,
    ),
  ];
  for (final (name, size, mode, scale, locale, contrast) in configs) {
    // Drop the previous screen (and its provider state) first.
    await tester.pumpWidget(const SizedBox());
    await pumpSaaf(
      tester,
      build(),
      size: size,
      themeMode: mode,
      textScale: scale,
      locale: locale,
      highContrast: contrast,
      scaffold: scaffold,
      overrides: overrides,
    );
    for (var i = 0; i < settlePumps; i++) {
      await tester.pump();
    }
    await after?.call();
    expect(tester.takeException(), isNull, reason: name);
  }
}
