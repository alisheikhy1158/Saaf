// Covers: Profile — change ONE answer in place (not the whole quiz again) and add
// a name and age (Phase 7 feedback from the first phone test)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_skin_profile_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/profile/screens/profile_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

import '../../../helpers/pump_app.dart';

const _profile = SkinProfile(
  skinType: SkinType.combination,
  concerns: {SkinConcern.acne},
  sensitivity: Sensitivity.sometimes,
  budget: BudgetBand.balanced,
);

List<Override> _with({
  AuthSession session = const AuthSession(
    userId: 'u',
    phoneE164: '+923144257707',
  ),
}) => [
  authSessionControllerProvider.overrideWithBuild((ref, n) => session),
  skinProfileControllerProvider.overrideWithBuild((ref, n) => _profile),
  // What is saved on the phone agrees with what is shown (as in the real app).
  skinProfileRepositoryProvider.overrideWithValue(
    InMemorySkinProfileRepository()..save(_profile),
  ),
];

Future<void> _open(WidgetTester tester, {List<Override>? overrides}) async {
  await pumpSaafApp(
    tester,
    location: '/profile',
    overrides: overrides ?? _with(),
  );
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
  group('Monthly budget: one question, then back to Profile', () {
    testWidgets('shows only the budget question, with Save and no Skip', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Monthly budget'));
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(find.textContaining('STEP'), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
    });

    testWidgets('Save keeps the new answer and returns to Profile', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Monthly budget'));
      await _tap(tester, find.text('Over Rs 10,000'));
      await _tap(tester, find.text('Save'));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        _container(tester).read(skinProfileControllerProvider).budget,
        BudgetBand.premium,
      );
    });

    testWidgets('Back leaves the answer as it was', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('Monthly budget'));
      await _tap(tester, find.text('Over Rs 10,000'));
      await _tap(tester, find.byTooltip('Back'));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        _container(tester).read(skinProfileControllerProvider).budget,
        BudgetBand.balanced,
      );
    });
  });

  group('Skin profile: pick which answer to change', () {
    testWidgets('lists the four skin answers with what is saved', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Skin profile'));
      expect(find.text('Skin type'), findsOneWidget);
      expect(find.text('Skin concerns'), findsOneWidget);
      expect(find.text('Sensitivity'), findsOneWidget);
      expect(find.text('Health & safety'), findsOneWidget);
    });

    testWidgets('Skin type opens only that question and Save returns', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Skin profile'));
      await _tap(tester, find.text('Skin type'));
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      await _tap(tester, find.text('Oily'));
      await _tap(tester, find.text('Save'));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        _container(tester).read(skinProfileControllerProvider).skinType,
        SkinType.oily,
      );
    });

    testWidgets('changing concerns does not touch the skin type', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Skin profile'));
      await _tap(tester, find.text('Skin concerns'));
      await _tap(tester, find.text('Dark spots & pigmentation'));
      await _tap(tester, find.text('Save'));
      final saved = _container(tester).read(skinProfileControllerProvider);
      expect(saved.skinType, SkinType.combination);
      expect(saved.concerns, contains(SkinConcern.darkSpots));
    });
  });

  group('Name and age', () {
    testWidgets('with only a phone number the title is the number', (
      tester,
    ) async {
      await _open(tester);
      expect(find.textContaining('7707'), findsOneWidget);
    });

    testWidgets('tapping the name opens the details sheet', (tester) async {
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('profile-identity')));
      expect(find.text('Your details'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('saving a name shows it on Profile and keeps it', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('profile-identity')));
      await tester.enterText(
        find.byKey(const ValueKey('details-name')),
        'Ayesha Khan',
      );
      await tester.enterText(find.byKey(const ValueKey('details-age')), '27');
      await _tap(tester, find.text('Save'));
      expect(find.text('Ayesha Khan'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      final saved = _container(tester).read(profileDetailsControllerProvider);
      expect(saved.name, 'Ayesha Khan');
      expect(saved.age, 27);
    });

    testWidgets('an age outside 16–99 is refused with a message', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('profile-identity')));
      await tester.enterText(
        find.byKey(const ValueKey('details-name')),
        'Ayesha',
      );
      await tester.enterText(find.byKey(const ValueKey('details-age')), '7');
      await _tap(tester, find.text('Save'));
      expect(find.text('Enter an age from 16 to 99.'), findsOneWidget);
      expect(
        _container(tester).read(profileDetailsControllerProvider).name,
        isNull,
      );
    });

    testWidgets('a name from sign-in is the starting point', (tester) async {
      await _open(
        tester,
        overrides: _with(
          session: const AuthSession(userId: 'u', displayName: 'Sana Malik'),
        ),
      );
      expect(find.text('Sana Malik'), findsOneWidget);
    });

    testWidgets('the name is checked for tap size and layout', (tester) async {
      await _open(tester);
      await _tap(tester, find.byKey(const ValueKey('profile-identity')));
      expect(tester.takeException(), isNull);
      await expectTapTargetsAccessible(tester);
    });
  });
}
