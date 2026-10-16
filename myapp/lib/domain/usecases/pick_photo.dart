import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/photo_picker.dart';

/// Uses an existing gallery photo for [FacePose]. Success with null = cancelled.
class PickPhoto {
  const PickPhoto({required PhotoPicker picker, required Clock clock})
    : _picker = picker,
      _clock = clock;

  final PhotoPicker _picker;
  final Clock _clock;

  Future<Result<ScanPhoto?>> call(FacePose pose) async {
    try {
      final picked = await _picker.pickFromGallery();
      final failure = picked.failureOrNull;
      if (failure != null) return Err(failure);
      final bytes = picked.valueOrNull;
      if (bytes == null) return const Ok(null);
      if (bytes.isEmpty) return const Err(UnknownFailure('empty-photo'));
      return Ok(ScanPhoto(pose: pose, bytes: bytes, capturedAt: _clock.now()));
    } on Object {
      return const Err(UnknownFailure('pick'));
    }
  }
}
