// Covers: architecture.md §2 (app.dart is the MaterialApp root),
// design.md §2.3–§2.4 (ThemeMode.system, high-contrast themes wired in)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

void main() {
  Future<MaterialApp> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SaafApp()));
    return tester.widget<MaterialApp>(find.byType(MaterialApp));
  }

  testWidgets('SaafApp builds a MaterialApp inside a ProviderScope', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('always light (no dark theme), with the Saaf themes', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    expect(app.themeMode, ThemeMode.light);
    expect(app.darkTheme, isNull);
    for (final theme in [app.theme, app.highContrastTheme]) {
      expect(theme?.extension<SaafTokens>(), isNotNull);
    }
  });

  testWidgets('a phone in dark mode still gets the light theme', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpApp(tester);
    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.light);
  });
}
