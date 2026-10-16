import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The next moment the clock shows [time], today or tomorrow.
tz.TZDateTime nextOccurrence(tz.TZDateTime now, ReminderTime time) {
  final today = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  return today.isAfter(now) ? today : today.add(const Duration(days: 1));
}

/// Daily reminders through `flutter_local_notifications` (phones).
///
/// Scheduled "inexact" on purpose: the phone may deliver a few minutes late,
/// but Android needs no special exact-alarm permission (which Google Play
/// restricts to alarm and calendar apps).
class PluginReminderScheduler implements ReminderScheduler {
  PluginReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'routine_reminders';
  static const _channelName = 'Routine reminders';
  static const _icon = '@mipmap/ic_launcher';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  Future<void> _init() => _ready ??= _setUp();

  Future<void> _setUp() async {
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
        // Our own explanation comes first: the system dialog is only shown
        // from the reminders sheet, never at start-up.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {
    await _init();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: nextOccurrence(now, reminder.time),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(_channelId, _channelName),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }
}
