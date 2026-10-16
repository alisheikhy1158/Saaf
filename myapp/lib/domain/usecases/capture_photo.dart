import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/services/camera_service.dart';
import 'package:saaf/domain/services/clock.dart';

/// Takes a photo with the camera for [FacePose].
class CapturePhoto {
  const CapturePhoto({required CameraService camera, required Clock clock})
    : _camera = camera,
      _clock = clock;

  final CameraService _camera;
  final Clock _clock;

  Future<Result<ScanPhoto>> call(FacePose pose) async {
    try {
      final shot = await _camera.capture();
      final bytes = shot.valueOrNull;
      if (bytes == null) return Err(shot.failureOrNull!);
      if (bytes.isEmpty) return const Err(UnknownFailure('empty-photo'));
      return Ok(ScanPhoto(pose: pose, bytes: bytes, capturedAt: _clock.now()));
    } on Object {
      return const Err(UnknownFailure('capture'));
    }
  }
}
