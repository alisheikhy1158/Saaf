import 'package:saaf/domain/entities/notification_permission.dart';

/// Notification permission only (iOS asks; Android 13+ asks; older Android is
/// always allowed).
abstract interface class NotificationPermissionService {
  Future<NotificationPermission> status();

  /// Shows the system dialog. Call it only after our own explanation sheet.
  Future<NotificationPermission> request();

  /// Opens the phone's settings page for this app.
  Future<bool> openSettings();
}
