import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';

/// Makes the phone's scheduled notifications match the reminder settings.
/// Never asks for permission (that is the user's choice, on the reminders
/// sheet): without it, nothing is scheduled.
class SyncReminders {
  const SyncReminders({
    required ReminderScheduler scheduler,
    required NotificationPermissionService permissions,
  }) : _scheduler = scheduler,
       _permissions = permissions;

  static const morningId = 1;
  static const nightId = 2;

  final ReminderScheduler _scheduler;
  final NotificationPermissionService _permissions;

  /// Returns true when at least one reminder is now scheduled.
  Future<bool> call(ReminderSettings settings, ReminderTexts texts) async {
    try {
      final reminders = [
        if (settings.morningOn)
          ScheduledReminder(
            id: morningId,
            time: settings.morning,
            title: texts.morningTitle,
            body: texts.morningBody,
          ),
        if (settings.nightOn)
          ScheduledReminder(
            id: nightId,
            time: settings.night,
            title: texts.nightTitle,
            body: texts.nightBody,
          ),
      ];
      final allowed =
          await _permissions.status() == NotificationPermission.granted;
      if (reminders.isEmpty || !allowed) {
        await _scheduler.cancelAll();
        return false;
      }
      await _scheduler.schedule(reminders);
      return true;
    } on Object {
      return false;
    }
  }
}
