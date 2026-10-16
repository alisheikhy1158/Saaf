import 'package:saaf/domain/entities/camera_permission.dart';

/// Camera permission only (the app never asks for photo-library, location or
/// contacts, PRV-3).
abstract interface class PermissionService {
  Future<CameraPermission> cameraStatus();

  /// Shows the system dialog. Call it only after our own rationale sheet.
  Future<CameraPermission> requestCamera();

  /// Opens the phone's settings page for this app.
  Future<bool> openSettings();
}
