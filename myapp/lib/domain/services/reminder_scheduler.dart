import 'package:saaf/domain/entities/reminder_settings.dart';

/// One notification that repeats every day at [time].
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.time,
    required this.title,
    required this.body,
  });

  final int id;
  final ReminderTime time;
  final String title;
  final String body;
}

/// The words on the notifications, in the app's current language.
class ReminderTexts {
  const ReminderTexts({
    required this.morningTitle,
    required this.morningBody,
    required this.nightTitle,
    required this.nightBody,
  });

  final String morningTitle;
  final String morningBody;
  final String nightTitle;
  final String nightBody;
}

/// Puts daily notifications on the phone. [schedule] replaces whatever was
/// scheduled before.
abstract interface class ReminderScheduler {
  Future<void> schedule(List<ScheduledReminder> reminders);

  Future<void> cancelAll();
}
