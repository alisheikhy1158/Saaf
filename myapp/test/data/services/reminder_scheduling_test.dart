// Covers: Phase 7 reminders — when the first notification fires, and that the
// words follow the app's language
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/plugin_reminder_scheduler.dart';
import 'package:saaf/data/services/web/fake_notification_permission_service.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/notification_providers.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('nextOccurrence', () {
    late tz.Location karachi;
    setUpAll(() {
      tz_data.initializeTimeZones();
      karachi = tz.getLocation('Asia/Karachi');
    });

    test('a time later today fires today', () {
      final now = tz.TZDateTime(karachi, 2026, 10, 16, 7, 30);
      final next = nextOccurrence(now, const ReminderTime(8, 0));
      expect(next, tz.TZDateTime(karachi, 2026, 10, 16, 8, 0));
    });

    test('a time that has passed fires tomorrow', () {
      final now = tz.TZDateTime(karachi, 2026, 10, 16, 9, 0);
      final next = nextOccurrence(now, const ReminderTime(8, 0));
      expect(next, tz.TZDateTime(karachi, 2026, 10, 17, 8, 0));
    });

    test('exactly now fires tomorrow, not in the past', () {
      final now = tz.TZDateTime(karachi, 2026, 10, 16, 8, 0);
      final next = nextOccurrence(now, const ReminderTime(8, 0));
      expect(next, tz.TZDateTime(karachi, 2026, 10, 17, 8, 0));
    });

    test('the last day of the month rolls over', () {
      final now = tz.TZDateTime(karachi, 2026, 10, 31, 23, 0);
      final next = nextOccurrence(now, const ReminderTime(22, 30));
      expect(next, tz.TZDateTime(karachi, 2026, 11, 1, 22, 30));
    });
  });

  group('notification words', () {
    test('English and Urdu', () {
      expect(
        reminderTextsFor(const Locale('en')).morningTitle,
        'Time for your morning routine',
      );
      expect(
        reminderTextsFor(const Locale('ur')).nightTitle,
        'رات کے روٹین کا وقت',
      );
    });

    test('a language the app does not have falls back to English', () {
      expect(
        reminderTextsFor(const Locale('fr')).nightTitle,
        'Time for your night routine',
      );
    });
  });

  group('the sync provider', () {
    ProviderContainer container(
      FakeReminderScheduler scheduler,
      NotificationPermission permission,
    ) {
      final c = ProviderContainer(
        overrides: [
          reminderSchedulerProvider.overrideWithValue(scheduler),
          notificationPermissionServiceProvider.overrideWithValue(
            FakeNotificationPermissionService(permission),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('schedules the saved reminders in the chosen language', () async {
      final scheduler = FakeReminderScheduler();
      final c = container(scheduler, NotificationPermission.granted);
      c.read(localeControllerProvider.notifier).setLocale(const Locale('ur'));
      expect(await c.read(reminderSyncProvider.future), isTrue);
      expect(scheduler.scheduled.map((r) => r.title), [
        'صبح کے روٹین کا وقت',
        'رات کے روٹین کا وقت',
      ]);
    });

    test('changing the language reschedules in the new language', () async {
      final scheduler = FakeReminderScheduler();
      final c = container(scheduler, NotificationPermission.granted);
      c.listen(reminderSyncProvider, (_, _) {});
      await c.read(reminderSyncProvider.future);
      c.read(localeControllerProvider.notifier).setLocale(const Locale('ur'));
      await c.read(reminderSyncProvider.future);
      expect(scheduler.scheduled.first.title, 'صبح کے روٹین کا وقت');
    });

    test('switching both off cancels everything', () async {
      final scheduler = FakeReminderScheduler();
      final c = container(scheduler, NotificationPermission.granted);
      c.listen(reminderSyncProvider, (_, _) {});
      await c.read(reminderSyncProvider.future);
      expect(scheduler.scheduled, hasLength(2));
      c
          .read(reminderSettingsControllerProvider.notifier)
          .set(const ReminderSettings(morningOn: false, nightOn: false));
      expect(await c.read(reminderSyncProvider.future), isFalse);
      expect(scheduler.scheduled, isEmpty);
    });

    test('without permission nothing is scheduled', () async {
      final scheduler = FakeReminderScheduler();
      final c = container(scheduler, NotificationPermission.denied);
      expect(await c.read(reminderSyncProvider.future), isFalse);
      expect(scheduler.scheduled, isEmpty);
    });
  });
}
