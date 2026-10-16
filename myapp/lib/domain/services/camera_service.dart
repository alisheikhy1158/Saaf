import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/camera_facing.dart';

/// The phone camera. The live preview widget is provided separately by the data
/// layer (see presentation/providers/camera_providers.dart); this interface is
/// pure Dart so the app runs in Chrome and tests with a fake.
abstract interface class CameraService {
  /// Starts the camera. Fails with `PermissionDenied` if the user refused access.
  Future<Result<void>> open(CameraFacing facing);

  /// Takes a photo (JPEG bytes).
  Future<Result<Uint8List>> capture();

  Future<void> close();

  /// Whether there is more than one camera to switch between.
  bool get canFlip;
}
