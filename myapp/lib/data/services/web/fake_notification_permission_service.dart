import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';

/// A notification permission you can steer (Chrome demos, tests): starts at
/// [initial], and answers the system dialog by granting or (when
/// [grantsOnRequest] is false) refusing for good.
class FakeNotificationPermissionService
    implements NotificationPermissionService {
  FakeNotificationPermissionService(
    NotificationPermission initial, {
    this.grantsOnRequest = true,
  }) : _status = initial;

  final bool grantsOnRequest;
  NotificationPermission _status;

  @override
  Future<NotificationPermission> status() async => _status;

  @override
  Future<NotificationPermission> request() async {
    _status = grantsOnRequest
        ? NotificationPermission.granted
        : NotificationPermission.permanentlyDenied;
    return _status;
  }

  @override
  Future<bool> openSettings() async => true;
}

/// Remembers what was scheduled instead of telling the phone (Chrome and tests).
class FakeReminderScheduler implements ReminderScheduler {
  List<ScheduledReminder> scheduled = const [];

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async =>
      scheduled = List.unmodifiable(reminders);

  @override
  Future<void> cancelAll() async => scheduled = const [];
}
