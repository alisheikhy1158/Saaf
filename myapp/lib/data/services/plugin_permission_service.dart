import 'package:permission_handler/permission_handler.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/services/permission_service.dart';

/// Translates the plugin's status into the app's three cases.
CameraPermission cameraPermissionFromStatus(PermissionStatus status) =>
    switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited => CameraPermission.granted,
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted => CameraPermission.permanentlyDenied,
      PermissionStatus.denied ||
      PermissionStatus.provisional => CameraPermission.denied,
    };

/// Camera permission through `permission_handler` (phones).
class PluginPermissionService implements PermissionService {
  const PluginPermissionService();

  @override
  Future<CameraPermission> cameraStatus() async {
    try {
      return cameraPermissionFromStatus(await Permission.camera.status);
    } on Object {
      return CameraPermission.denied;
    }
  }

  @override
  Future<CameraPermission> requestCamera() async {
    try {
      return cameraPermissionFromStatus(await Permission.camera.request());
    } on Object {
      return CameraPermission.denied;
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
