// Covers: choosing a city during setup (for the daily skin weather), with no
// location permission; skippable; then on to the face scan
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/presentation/features/onboarding/screens/choose_city_screen.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late InMemorySettingsRepository settings;
  setUp(() => settings = InMemorySettingsRepository());

  Future<void> open(WidgetTester tester) async {
    await pumpSaafApp(
      tester,
      location: '/choose-city',
      overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('choosing a city saves it and goes on to the face scan', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Which city do you live in?'), findsOneWidget);
    expect(find.textContaining('never your exact location'), findsOneWidget);
    await tap(tester, 'Lahore');
    await tap(tester, 'Continue');
    expect(await settings.read(SettingNames.weatherCity), 'lahore');
    expect(find.byKey(const ValueKey('screen-selfieCapture')), findsOneWidget);
  });

  testWidgets('can be skipped', (tester) async {
    await open(tester);
    await tap(tester, 'Skip');
    expect(await settings.read(SettingNames.weatherCity), isNull);
    expect(find.byKey(const ValueKey('screen-selfieCapture')), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await expectRobustLayoutSettled(
      tester,
      () => const ChooseCityScreen(),
      scaffold: false,
      overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
    );
  });
}
