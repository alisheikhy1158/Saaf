// Covers: SaafDarkScope — the always-dark camera screen (design.md §2.3)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/widgets/common/saaf_dark_scope.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<Color> surfaceUnder(
    WidgetTester tester, {
    ThemeMode mode = ThemeMode.light,
    bool highContrast = false,
  }) async {
    late Color surface;
    await pumpSaaf(
      tester,
      SaafDarkScope(
        child: Builder(
          builder: (context) {
            surface = Theme.of(context).colorScheme.surface;
            return const SizedBox();
          },
        ),
      ),
      themeMode: mode,
      highContrast: highContrast,
    );
    return surface;
  }

  testWidgets('is ink even when the app is light', (tester) async {
    expect(await surfaceUnder(tester), SaafPalette.ink);
  });

  testWidgets('stays ink in dark mode', (tester) async {
    expect(await surfaceUnder(tester, mode: ThemeMode.dark), SaafPalette.ink);
  });

  testWidgets('follows the high-contrast setting', (tester) async {
    expect(await surfaceUnder(tester, highContrast: true), SaafPalette.ink);
  });
}
