import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show DeviceOrientation;

/// One picture from the running camera, with what is needed to turn it upright.
class LiveFrame {
  const LiveFrame({
    required this.image,
    required this.sensorOrientation,
    required this.front,
    required this.deviceOrientation,
  });

  final CameraImage image;
  final int sensorOrientation;

  /// From the front (selfie) camera.
  final bool front;
  final DeviceOrientation deviceOrientation;
}

/// A camera that can hand out its live pictures (phones only).
abstract interface class LiveFrameSource {
  /// Pictures while the camera runs. Listening starts the stream; cancelling
  /// stops it. Errors if the camera is not open.
  Stream<LiveFrame> liveFrames();
}
