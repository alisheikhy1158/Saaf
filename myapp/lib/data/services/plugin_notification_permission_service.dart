import 'package:permission_handler/permission_handler.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';

/// Translates the plugin's status into the app's three cases.
NotificationPermission notificationPermissionFromStatus(
  PermissionStatus status,
) => switch (status) {
  PermissionStatus.granted ||
  PermissionStatus.limited ||
  PermissionStatus.provisional => NotificationPermission.granted,
  PermissionStatus.permanentlyDenied ||
  PermissionStatus.restricted => NotificationPermission.permanentlyDenied,
  PermissionStatus.denied => NotificationPermission.denied,
};

/// Notification permission through `permission_handler` (phones).
class PluginNotificationPermissionService
    implements NotificationPermissionService {
  const PluginNotificationPermissionService();

  @override
  Future<NotificationPermission> status() async {
    try {
      return notificationPermissionFromStatus(
        await Permission.notification.status,
      );
    } on Object {
      return NotificationPermission.denied;
    }
  }

  @override
  Future<NotificationPermission> request() async {
    try {
      return notificationPermissionFromStatus(
        await Permission.notification.request(),
      );
    } on Object {
      return NotificationPermission.denied;
    }
  }

  @override
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } on Object {
      return false;
    }
  }
}
