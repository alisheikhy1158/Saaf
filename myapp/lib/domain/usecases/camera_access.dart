import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/services/permission_service.dart';

/// What the scan screen should do about the camera permission
/// (store-compliance.md §1).
enum CameraAccessOutcome {
  /// Open the camera.
  granted,

  /// Show our explanation sheet first; only "Continue" asks the system.
  needsRationale,

  /// The user refused: explain, keep the app usable, allow trying again later.
  denied,

  /// Refused for good: offer to open the phone's settings.
  needsSettings,
}

class CameraAccess {
  const CameraAccess(this._permissions);

  final PermissionService _permissions;

  Future<CameraAccessOutcome> check() async =>
      _outcome(await _permissions.cameraStatus(), asked: false);

  /// Asks the system. Call after the rationale sheet's "Continue".
  Future<CameraAccessOutcome> request() async {
    final current = await _permissions.cameraStatus();
    if (current == CameraPermission.granted) return CameraAccessOutcome.granted;
    return _outcome(await _permissions.requestCamera(), asked: true);
  }

  Future<bool> openSettings() => _permissions.openSettings();

  static CameraAccessOutcome _outcome(
    CameraPermission status, {
    required bool asked,
  }) => switch (status) {
    CameraPermission.granted => CameraAccessOutcome.granted,
    CameraPermission.denied =>
      asked ? CameraAccessOutcome.denied : CameraAccessOutcome.needsRationale,
    CameraPermission.permanentlyDenied => CameraAccessOutcome.needsSettings,
  };
}
