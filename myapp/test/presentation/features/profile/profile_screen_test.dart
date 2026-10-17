// Covers: Figma 14 Profile & privacy (node 3:801) + store-compliance A-1 (delete
// account in the app), §4 (Terms and Privacy reachable), design.md §10 (theme
// row), A11Y-1/2/3/5/6/8
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/fake_auth_repository.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/profile/screens/profile_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';

import '../../../helpers/pump_app.dart';

const _profile = SkinProfile(
  skinType: SkinType.combination,
  concerns: {SkinConcern.acne, SkinConcern.darkSpots},
  budget: BudgetBand.balanced,
);

/// A fake backend that refuses to delete.
class _RefusingAuth extends FakeAuthRepository {
  _RefusingAuth(this.failure);
  final Failure failure;

  @override
  Future<Result<void>> deleteAccount() async => Err(failure);
}

List<Override> _with({
  AuthSession? session = const AuthSession(
    userId: 'u',
    displayName: 'Ayesha Khan',
  ),
  SkinProfile profile = _profile,
  bool pro = false,
  FakeAuthRepository? auth,
  InMemoryPhotoStore? photos,
  bool pinProfile = true,
}) => [
  authSessionControllerProvider.overrideWithBuild((ref, n) => session),
  // A pinned profile cannot be wiped, so the delete test sets it by hand.
  if (pinProfile)
    skinProfileControllerProvider.overrideWithBuild((ref, n) => profile),
  proStatusProvider.overrideWithBuild((ref, n) => pro),
  authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
  photoStoreProvider.overrideWithValue(photos ?? InMemoryPhotoStore()),
];

Future<void> _open(
  WidgetTester tester, {
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const ProfileScreen(),
    scaffold: false,
    size: size,
    overrides: overrides ?? _with(),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _app(WidgetTester tester, {List<Override>? overrides}) async {
  await pumpSaafApp(
    tester,
    location: '/profile',
    overrides: overrides ?? _with(),
  );
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

void main() {
  group('identity', () {
    testWidgets('shows the name, the initial and the skin line', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Ayesha Khan'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Combination skin · Acne-prone'), findsOneWidget);
    });

    testWidgets('without a name it falls back to the phone number', (
      tester,
    ) async {
      await _open(
        tester,
        overrides: _with(
          session: const AuthSession(userId: 'u', phoneE164: '+923124567890'),
        ),
      );
      expect(find.text('Phone ending 7890'), findsOneWidget);
    });

    testWidgets('with nothing known it says Saaf member', (tester) async {
      await _open(tester, overrides: _with(session: null));
      expect(find.text('Saaf member'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });
  });

  group('Pro card', () {
    testWidgets('free users are offered Pro', (tester) async {
      await _open(tester);
      expect(find.text('You’re on the free plan'), findsOneWidget);
      expect(find.text('Unlock photo tracking every 2 weeks'), findsOneWidget);
      expect(find.text('Go Pro'), findsOneWidget);
    });

    testWidgets('Pro users are thanked', (tester) async {
      await _open(tester, overrides: _with(pro: true));
      expect(find.text('You’re on Saaf Pro'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('Go Pro'), findsNothing);
    });

    testWidgets('Go Pro opens the paywall', (tester) async {
      await _app(tester);
      await _tap(tester, find.text('Go Pro'));
      expect(find.byKey(const ValueKey('screen-paywall')), findsOneWidget);
    });
  });

  group('rows and their values', () {
    testWidgets('routine group', (tester) async {
      await _open(tester);
      expect(find.text('Routine'.toUpperCase()), findsOneWidget);
      expect(find.text('Skin profile'), findsOneWidget);
      expect(find.text('Combination, breakouts, dark spots'), findsOneWidget);
      expect(find.text('Monthly budget'), findsOneWidget);
      expect(find.text('Rs 6,000'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('8:00 · 22:30'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('privacy group', (tester) async {
      await _open(tester);
      expect(find.text('Privacy'.toUpperCase()), findsOneWidget);
      expect(find.text('Photo backup'), findsOneWidget);
      expect(find.text('Off'), findsWidgets);
      expect(find.text('Delete my account'), findsOneWidget);
    });

    testWidgets('app group: appearance, legal and log out', (tester) async {
      await _open(tester);
      await tester.ensureVisible(find.text('Log out'));
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('no answers: values say Not set', (tester) async {
      await _open(tester, overrides: _with(profile: const SkinProfile()));
      // Skin profile, budget, and the event (Life events) row.
      expect(find.text('Not set'), findsNWidgets(3));
    });

    testWidgets('the highest budget band has no limit', (tester) async {
      await _open(
        tester,
        overrides: _with(
          profile: const SkinProfile(budget: BudgetBand.premium),
        ),
      );
      expect(find.text('No limit'), findsOneWidget);
    });
  });

  group('editing the routine answers', () {
    // Changed on purpose (first phone test): a row now edits ONLY its own
    // answer instead of restarting the whole quiz — see profile_editing_test.
    testWidgets('Skin profile lets you pick which answer to change', (
      tester,
    ) async {
      await _app(tester);
      await _tap(tester, find.text('Skin profile'));
      expect(find.text('Skin concerns'), findsOneWidget);
      expect(find.byKey(const ValueKey('screen-skinQuiz')), findsNothing);
    });

    testWidgets('Monthly budget opens the budget step', (tester) async {
      await _app(tester);
      await _tap(tester, find.text('Monthly budget'));
      expect(find.byKey(const ValueKey('screen-skinQuiz-5')), findsOneWidget);
    });
  });

  group('sheets', () {
    testWidgets('Reminders: switch the night reminder off', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('Reminders'));
      expect(find.text('Morning routine'), findsOneWidget);
      expect(find.text('Night routine'), findsOneWidget);
      expect(
        find.text('Saaf reminds you every day at these times.'),
        findsOneWidget,
      );
      await _tap(tester, find.byType(Switch).last);
      expect(
        _container(tester).read(reminderSettingsControllerProvider).nightOn,
        isFalse,
      );
      await _tap(tester, find.text('Done'));
      expect(find.text('8:00'), findsOneWidget);
    });

    testWidgets('Language: switching to Urdu changes the app', (tester) async {
      await _app(tester);
      await _tap(tester, find.text('Language'));
      await _tap(tester, find.text('اردو'));
      expect(
        _container(tester).read(localeControllerProvider),
        const Locale('ur'),
      );
      expect(find.text('پروفائل'), findsOneWidget);
    });

    testWidgets('Appearance: choosing Dark', (tester) async {
      await _open(tester);
      await _tap(tester, find.text('Appearance'));
      await _tap(tester, find.text('Dark'));
      expect(
        _container(tester).read(themeModeControllerProvider),
        ThemeMode.dark,
      );
    });

    testWidgets('Photo backup explains that photos stay on the phone', (
      tester,
    ) async {
      await _open(tester);
      await _tap(tester, find.text('Photo backup'));
      expect(find.textContaining('stay only on this phone'), findsOneWidget);
    });
  });

  group('legal', () {
    testWidgets('Terms of Use and Privacy Policy open their pages', (
      tester,
    ) async {
      await _app(tester);
      await _tap(tester, find.text('Terms of Use'));
      expect(find.byKey(const ValueKey('screen-terms')), findsOneWidget);
    });

    testWidgets('the Privacy Policy opens too', (tester) async {
      await _app(tester);
      await _tap(tester, find.text('Privacy Policy'));
      expect(
        find.byKey(const ValueKey('screen-privacyPolicy')),
        findsOneWidget,
      );
    });
  });

  group('log out', () {
    testWidgets('asks first, then signs out and goes to Welcome', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await _app(tester, overrides: _with(auth: auth));
      await _tap(tester, find.text('Log out'));
      expect(find.text('Log out?'), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(find.text('Log out?'), findsNothing);
      expect(find.byKey(const ValueKey('screen-profile')), findsOneWidget);

      await _tap(tester, find.text('Log out'));
      await _tap(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log out'),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-welcome')), findsOneWidget);
    });
  });

  group('delete account', () {
    testWidgets('explains what goes, and Cancel changes nothing', (
      tester,
    ) async {
      await _app(tester);
      await _tap(tester, find.text('Delete my account'));
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(find.textContaining('This cannot be undone'), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(find.text('Delete your account?'), findsNothing);
      expect(find.byKey(const ValueKey('screen-profile')), findsOneWidget);
    });

    testWidgets('confirming removes the account, the photos and the answers', (
      tester,
    ) async {
      final photos = InMemoryPhotoStore();
      final stored = (await photos.save(
        scanId: 'scan-1',
        pose: FacePose.front,
        bytes: Uint8List.fromList([1, 2, 3]),
      )).valueOrNull!;
      await _app(
        tester,
        overrides: _with(photos: photos, pinProfile: false, session: null),
      );
      final container = _container(tester);
      container.read(skinProfileControllerProvider.notifier).set(_profile);
      container
          .read(scanHistoryProvider.notifier)
          .add(
            CompletedScan(
              id: 'scan-1',
              takenAt: DateTime(2026, 10, 1),
              photos: [stored],
            ),
          );

      await _tap(tester, find.text('Delete my account'));
      await _tap(tester, find.text('Delete everything'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const ValueKey('screen-welcome')), findsOneWidget);
      expect((await photos.load(stored)).isOk, isFalse);
      expect(container.read(scanHistoryProvider), isEmpty);
      expect(
        container.read(skinProfileControllerProvider),
        const SkinProfile(),
      );
      expect(container.read(authSessionControllerProvider), isNull);
    });

    testWidgets(
      'an old login asks the user to log in again, and keeps everything',
      (tester) async {
        final photos = InMemoryPhotoStore();
        final stored = (await photos.save(
          scanId: 'scan-1',
          pose: FacePose.front,
          bytes: Uint8List.fromList([1]),
        )).valueOrNull!;
        await _app(
          tester,
          overrides: _with(
            photos: photos,
            auth: _RefusingAuth(const UnknownFailure('requires-recent-login')),
          ),
        );
        _container(tester)
            .read(scanHistoryProvider.notifier)
            .add(
              CompletedScan(
                id: 'scan-1',
                takenAt: DateTime(2026, 10, 1),
                photos: [stored],
              ),
            );

        await _tap(tester, find.text('Delete my account'));
        await _tap(tester, find.text('Delete everything'));
        expect(
          find.text(
            'For your security, please log in again and then delete your account.',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('screen-profile')), findsOneWidget);
        expect((await photos.load(stored)).isOk, isTrue);
      },
    );

    testWidgets('any other failure says so and can be retried', (tester) async {
      await _app(
        tester,
        overrides: _with(auth: _RefusingAuth(const NetworkFailure())),
      );
      await _tap(tester, find.text('Delete my account'));
      await _tap(tester, find.text('Delete everything'));
      expect(
        find.text('We couldn’t delete your account. Please try again.'),
        findsOneWidget,
      );
    });
  });

  group('navigation', () {
    testWidgets('lives in the bottom navigation with Profile selected', (
      tester,
    ) async {
      await _open(tester);
      for (final label in ['Home', 'Scan', 'Progress', 'Profile']) {
        expect(find.byTooltip(label), findsOneWidget, reason: label);
      }
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const ProfileScreen(),
        scaffold: false,
        overrides: _with(),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('a Pro user with no answers is robust too', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const ProfileScreen(),
        scaffold: false,
        overrides: _with(
          pro: true,
          session: null,
          profile: const SkinProfile(),
        ),
      );
    });
  });
}
