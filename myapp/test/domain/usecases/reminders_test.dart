// Covers: Phase 7 reminders — notification permission with our own explanation
// first (store-compliance), and daily notifications for the chosen times
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';
import 'package:saaf/domain/usecases/notification_access.dart';
import 'package:saaf/domain/usecases/sync_reminders.dart';

class _Permissions implements NotificationPermissionService {
  _Permissions(this.current, {this.afterRequest});
  NotificationPermission current;
  NotificationPermission? afterRequest;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<NotificationPermission> status() async => current;

  @override
  Future<NotificationPermission> request() async {
    requests++;
    return current = afterRequest ?? current;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class _Scheduler implements ReminderScheduler {
  List<ScheduledReminder>? applied;
  int cancels = 0;

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async =>
      applied = reminders;

  @override
  Future<void> cancelAll() async {
    cancels++;
    applied = null;
  }
}

const _texts = ReminderTexts(
  morningTitle: 'Morning',
  morningBody: 'Cleanse',
  nightTitle: 'Night',
  nightBody: 'Moisturise',
);

void main() {
  group('NotificationAccess', () {
    test('already allowed: go ahead', () async {
      final access = NotificationAccess(
        _Permissions(NotificationPermission.granted),
      );
      expect(await access.check(), NotificationAccessOutcome.granted);
    });

    test('not asked yet: our own explanation first', () async {
      final access = NotificationAccess(
        _Permissions(NotificationPermission.denied),
      );
      expect(await access.check(), NotificationAccessOutcome.needsRationale);
    });

    test('blocked for good: only Settings can help', () async {
      final access = NotificationAccess(
        _Permissions(NotificationPermission.permanentlyDenied),
      );
      expect(await access.check(), NotificationAccessOutcome.needsSettings);
    });

    test('after the explanation, asking can grant', () async {
      final permissions = _Permissions(
        NotificationPermission.denied,
        afterRequest: NotificationPermission.granted,
      );
      expect(
        await NotificationAccess(permissions).request(),
        NotificationAccessOutcome.granted,
      );
      expect(permissions.requests, 1);
    });

    test(
      'refusing the system dialog is "denied" (can try again later)',
      () async {
        final permissions = _Permissions(NotificationPermission.denied);
        expect(
          await NotificationAccess(permissions).request(),
          NotificationAccessOutcome.denied,
        );
      },
    );

    test('already allowed: the system is not asked again', () async {
      final permissions = _Permissions(NotificationPermission.granted);
      expect(
        await NotificationAccess(permissions).request(),
        NotificationAccessOutcome.granted,
      );
      expect(permissions.requests, 0);
    });

    test('openSettings goes to the phone settings', () async {
      final permissions = _Permissions(
        NotificationPermission.permanentlyDenied,
      );
      await NotificationAccess(permissions).openSettings();
      expect(permissions.settingsOpened, 1);
    });
  });

  group('SyncReminders', () {
    test(
      'both on and allowed: two daily notifications at the chosen times',
      () async {
        final scheduler = _Scheduler();
        final active = await SyncReminders(
          scheduler: scheduler,
          permissions: _Permissions(NotificationPermission.granted),
        )(const ReminderSettings(), _texts);
        expect(active, isTrue);
        expect(
          scheduler.applied!.map((r) => (r.id, r.time.text, r.title, r.body)),
          [
            (SyncReminders.morningId, '8:00', 'Morning', 'Cleanse'),
            (SyncReminders.nightId, '22:30', 'Night', 'Moisturise'),
          ],
        );
      },
    );

    test('only the ones that are on', () async {
      final scheduler = _Scheduler();
      await SyncReminders(
        scheduler: scheduler,
        permissions: _Permissions(NotificationPermission.granted),
      )(const ReminderSettings(morningOn: false), _texts);
      expect(scheduler.applied!.map((r) => r.id), [SyncReminders.nightId]);
    });

    test('both off: everything cancelled', () async {
      final scheduler = _Scheduler();
      final active = await SyncReminders(
        scheduler: scheduler,
        permissions: _Permissions(NotificationPermission.granted),
      )(const ReminderSettings(morningOn: false, nightOn: false), _texts);
      expect(active, isFalse);
      expect(scheduler.cancels, 1);
      expect(scheduler.applied, isNull);
    });

    test(
      'no permission: nothing is scheduled and old ones are cancelled',
      () async {
        final scheduler = _Scheduler();
        final active = await SyncReminders(
          scheduler: scheduler,
          permissions: _Permissions(NotificationPermission.denied),
        )(const ReminderSettings(), _texts);
        expect(active, isFalse);
        expect(scheduler.cancels, 1);
        expect(scheduler.applied, isNull);
      },
    );

    test(
      'a scheduler that fails reports not active instead of throwing',
      () async {
        final active = await SyncReminders(
          scheduler: _Failing(),
          permissions: _Permissions(NotificationPermission.granted),
        )(const ReminderSettings(), _texts);
        expect(active, isFalse);
      },
    );
  });
}

class _Failing extends _Scheduler {
  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async =>
      throw StateError('x');
}
