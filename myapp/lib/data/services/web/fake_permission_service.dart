import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/services/permission_service.dart';

/// A permission service you can steer: starts at [initial], and answers the
/// system dialog by granting or (when [grantsOnRequest] is false) refusing for good.
class FakePermissionService implements PermissionService {
  FakePermissionService(CameraPermission initial, {this.grantsOnRequest = true})
    : _status = initial;

  final bool grantsOnRequest;
  CameraPermission _status;

  @override
  Future<CameraPermission> cameraStatus() async => _status;

  @override
  Future<CameraPermission> requestCamera() async {
    _status = grantsOnRequest
        ? CameraPermission.granted
        : CameraPermission.permanentlyDenied;
    return _status;
  }

  @override
  Future<bool> openSettings() async => true;
}
