// Covers: Phase 7 reminders on the Profile sheet — our own explanation before the
// system notification dialog (store-compliance §1), a way forward when it is
// refused or blocked, and the reminders really being scheduled
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/web/fake_notification_permission_service.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/presentation/features/profile/screens/profile_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';

import '../../../helpers/pump_app.dart';

class _Opened extends FakeNotificationPermissionService {
  _Opened(super.initial, {super.grantsOnRequest});
  int settingsOpened = 0;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

Future<void> _open(
  WidgetTester tester, {
  required NotificationPermission permission,
  bool grantsOnRequest = true,
  _Opened? service,
  FakeReminderScheduler? scheduler,
  ReminderSettings settings = const ReminderSettings(
    morningOn: false,
    nightOn: false,
  ),
}) async {
  final permissions =
      service ?? _Opened(permission, grantsOnRequest: grantsOnRequest);
  await pumpSaafApp(
    tester,
    location: '/profile',
    permissions: permissions,
    scheduler: scheduler,
    overrides: <Override>[
      authSessionControllerProvider.overrideWithBuild(
        (ref, n) => const AuthSession(userId: 'u', displayName: 'Ayesha Khan'),
      ),
    ],
  );
  await tester.pump();
  ProviderScope.containerOf(
    tester.element(find.byType(ProfileScreen)),
  ).read(reminderSettingsControllerProvider.notifier).set(settings);
  await tester.pump();
  await _tap(tester, find.text('Reminders'));
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
  group('turning a reminder on', () {
    testWidgets('not asked yet: our explanation comes first', (tester) async {
      final permissions = _Opened(NotificationPermission.denied);
      await _open(
        tester,
        permission: NotificationPermission.denied,
        service: permissions,
      );
      await _tap(tester, find.byType(Switch).first);
      expect(find.text('Allow notifications'), findsOneWidget);
      expect(find.textContaining('one gentle reminder'), findsOneWidget);
      // Nothing is switched on, and the system was not asked, until "Continue".
      expect(
        _container(tester).read(reminderSettingsControllerProvider).morningOn,
        isFalse,
      );
      expect(await permissions.status(), NotificationPermission.denied);
    });

    testWidgets('Continue, then allowed: the reminder is on and scheduled', (
      tester,
    ) async {
      final scheduler = FakeReminderScheduler();
      await _open(
        tester,
        permission: NotificationPermission.denied,
        scheduler: scheduler,
      );
      await _tap(tester, find.byType(Switch).first);
      await _tap(tester, find.text('Continue'));
      expect(
        _container(tester).read(reminderSettingsControllerProvider).morningOn,
        isTrue,
      );
      await tester.pump();
      expect(scheduler.scheduled.map((r) => r.time.text), ['8:00']);
      expect(scheduler.scheduled.single.title, 'Time for your morning routine');
    });

    testWidgets('Not now: stays off and says nothing scary', (tester) async {
      final scheduler = FakeReminderScheduler();
      await _open(
        tester,
        permission: NotificationPermission.denied,
        scheduler: scheduler,
      );
      await _tap(tester, find.byType(Switch).first);
      await _tap(tester, find.text('Not now'));
      expect(
        _container(tester).read(reminderSettingsControllerProvider).morningOn,
        isFalse,
      );
      expect(scheduler.scheduled, isEmpty);
      expect(find.text('Morning routine'), findsOneWidget);
    });

    testWidgets('refused in the system dialog: stays off and offers Settings', (
      tester,
    ) async {
      await _open(
        tester,
        permission: NotificationPermission.denied,
        grantsOnRequest: false,
      );
      await _tap(tester, find.byType(Switch).first);
      await _tap(tester, find.text('Continue'));
      expect(
        _container(tester).read(reminderSettingsControllerProvider).morningOn,
        isFalse,
      );
      expect(find.textContaining('blocked for Saaf'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('blocked earlier: no dialog, Open Settings goes to the phone', (
      tester,
    ) async {
      final permissions = _Opened(NotificationPermission.permanentlyDenied);
      await _open(
        tester,
        permission: NotificationPermission.permanentlyDenied,
        service: permissions,
      );
      await _tap(tester, find.byType(Switch).first);
      expect(find.text('Allow notifications'), findsNothing);
      expect(find.textContaining('blocked for Saaf'), findsOneWidget);
      await _tap(tester, find.text('Open Settings'));
      expect(permissions.settingsOpened, 1);
    });

    testWidgets('already allowed: switches straight on', (tester) async {
      await _open(tester, permission: NotificationPermission.granted);
      await _tap(tester, find.byType(Switch).last);
      expect(find.text('Allow notifications'), findsNothing);
      expect(
        _container(tester).read(reminderSettingsControllerProvider).nightOn,
        isTrue,
      );
    });
  });

  group('turning a reminder off', () {
    testWidgets('needs no permission and cancels the notification', (
      tester,
    ) async {
      final scheduler = FakeReminderScheduler();
      await _open(
        tester,
        permission: NotificationPermission.granted,
        scheduler: scheduler,
        settings: const ReminderSettings(),
      );
      expect(scheduler.scheduled, hasLength(2));
      await _tap(tester, find.byType(Switch).last);
      await tester.pump();
      expect(scheduler.scheduled.map((r) => r.id), [1]);
    });
  });

  group('reminders that are on but notifications are not allowed', () {
    testWidgets('the sheet says so and offers to allow them', (tester) async {
      await _open(
        tester,
        permission: NotificationPermission.denied,
        settings: const ReminderSettings(),
      );
      expect(find.text('Allow notifications'), findsOneWidget);
      await _tap(tester, find.text('Allow notifications'));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('allowed: no warning', (tester) async {
      await _open(
        tester,
        permission: NotificationPermission.granted,
        settings: const ReminderSettings(),
      );
      expect(find.text('Allow notifications'), findsNothing);
      expect(find.textContaining('blocked for Saaf'), findsNothing);
    });
  });
}
