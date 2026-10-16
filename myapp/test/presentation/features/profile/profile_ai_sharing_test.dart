// Covers: Profile — see and withdraw permission to share chats with the AI
// coach (Apple 5.1.2(i): the user stays in control)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/presentation/features/profile/screens/profile_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

List<Override> _overrides(InMemorySettingsRepository settings) => [
  authSessionControllerProvider.overrideWithBuild(
    (ref, n) => const AuthSession(userId: 'u', displayName: 'Ayesha'),
  ),
  settingsRepositoryProvider.overrideWithValue(settings),
];

Future<void> _open(
  WidgetTester tester,
  InMemorySettingsRepository settings,
) async {
  await pumpSaafApp(
    tester,
    location: '/profile',
    overrides: _overrides(settings),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ProfileScreen)));

void main() {
  testWidgets('shows Off until the user has agreed', (tester) async {
    await _open(tester, InMemorySettingsRepository());
    expect(find.text('AI coach sharing'), findsOneWidget);
    final row = find.bySemanticsLabel('AI coach sharing, Off');
    expect(row, findsOneWidget);
  });

  testWidgets('shows On after agreeing', (tester) async {
    final settings = InMemorySettingsRepository();
    await settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 17).toIso8601String(),
    );
    await _open(tester, settings);
    expect(find.bySemanticsLabel('AI coach sharing, On'), findsOneWidget);
  });

  testWidgets('the sheet explains and switches it off', (tester) async {
    final settings = InMemorySettingsRepository();
    await settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 17).toIso8601String(),
    );
    await _open(tester, settings);
    await _tap(tester, find.text('AI coach sharing'));
    expect(find.textContaining('Privacy Policy'), findsWidgets);
    expect(find.text('Share with the AI coach'), findsOneWidget);
    await _tap(tester, find.byType(Switch));
    expect(_container(tester).read(aiConsentStateProvider), isFalse);
    expect(await settings.read(AiConsent.settingName), isNull);
  });

  testWidgets('the sheet can switch it on too', (tester) async {
    final settings = InMemorySettingsRepository();
    await _open(tester, settings);
    await _tap(tester, find.text('AI coach sharing'));
    await _tap(tester, find.byType(Switch));
    expect(_container(tester).read(aiConsentStateProvider), isTrue);
    expect(await settings.read(AiConsent.settingName), isNotNull);
  });
}
