import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';

/// What the reminders screen should do about the notification permission
/// (store-compliance.md §1).
enum NotificationAccessOutcome {
  /// Schedule the reminders.
  granted,

  /// Show our explanation sheet first; only "Continue" asks the system.
  needsRationale,

  /// The user refused: explain, keep the app usable, allow trying again later.
  denied,

  /// Refused for good: offer to open the phone's settings.
  needsSettings,
}

class NotificationAccess {
  const NotificationAccess(this._permissions);

  final NotificationPermissionService _permissions;

  Future<NotificationAccessOutcome> check() async =>
      _outcome(await _permissions.status(), asked: false);

  /// Asks the system. Call after the explanation sheet's "Continue".
  Future<NotificationAccessOutcome> request() async {
    final current = await _permissions.status();
    if (current == NotificationPermission.granted) {
      return NotificationAccessOutcome.granted;
    }
    return _outcome(await _permissions.request(), asked: true);
  }

  Future<bool> openSettings() => _permissions.openSettings();

  static NotificationAccessOutcome _outcome(
    NotificationPermission status, {
    required bool asked,
  }) => switch (status) {
    NotificationPermission.granted => NotificationAccessOutcome.granted,
    NotificationPermission.denied =>
      asked
          ? NotificationAccessOutcome.denied
          : NotificationAccessOutcome.needsRationale,
    NotificationPermission.permanentlyDenied =>
      NotificationAccessOutcome.needsSettings,
  };
}
