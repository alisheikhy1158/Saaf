import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:saaf/domain/entities/frame_measurement.dart';

/// How much the camera frame must be turned to stand upright, in the form the
/// face detector wants (the standard recipe from the ML Kit camera example).
/// Null on platforms without a face detector.
InputImageRotation? imageRotation({
  required int sensorOrientation,
  required DeviceOrientation deviceOrientation,
  required bool frontCamera,
  required TargetPlatform platform,
}) {
  switch (platform) {
    case TargetPlatform.iOS:
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    case TargetPlatform.android:
      final device = switch (deviceOrientation) {
        DeviceOrientation.portraitUp => 0,
        DeviceOrientation.landscapeLeft => 90,
        DeviceOrientation.portraitDown => 180,
        DeviceOrientation.landscapeRight => 270,
      };
      final turned = frontCamera
          ? (sensorOrientation + device) % 360
          : (sensorOrientation - device + 360) % 360;
      return InputImageRotationValue.fromRawValue(turned);
    case TargetPlatform.fuchsia ||
        TargetPlatform.linux ||
        TargetPlatform.macOS ||
        TargetPlatform.windows:
      return null;
  }
}

/// The size of the picture once it is upright (a sideways sensor image has its
/// width and height swapped).
Size uprightSize(Size raw, InputImageRotation rotation) =>
    rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg
    ? Size(raw.height, raw.width)
    : raw;

/// A detected face as the scan rules see it: position and size as fractions of
/// the upright picture. [mirrored] when the frame is a mirror image (iOS front
/// camera), which flips the head turn.
FaceObservation observationFrom({
  required Rect box,
  required double? yaw,
  required double? roll,
  required Size upright,
  required bool mirrored,
}) {
  final flip = mirrored ? -1.0 : 1.0;
  return FaceObservation(
    centerX: box.center.dx / upright.width,
    centerY: box.center.dy / upright.height,
    widthFraction: box.width / upright.width,
    yawDegrees: (yaw ?? 0) * flip,
    rollDegrees: (roll ?? 0) * flip,
  );
}

/// Average brightness (0–255) of the middle of a camera frame, where the face
/// is when it is centred. [bgra] frames (iOS) have 4 bytes per pixel; the
/// Android NV21 frame starts with one brightness byte per pixel.
double meanBrightness({
  required Uint8List bytes,
  required int width,
  required int height,
  required int bytesPerRow,
  required bool bgra,
}) {
  if (width <= 0 || height <= 0 || bytes.isEmpty) return 128;
  final left = width ~/ 4;
  final right = width - width ~/ 4;
  final top = height ~/ 4;
  final bottom = height - height ~/ 4;
  // At most about 40 samples each way: plenty for an average, and cheap.
  final stepX = ((right - left) ~/ 40).clamp(1, 1 << 20);
  final stepY = ((bottom - top) ~/ 40).clamp(1, 1 << 20);

  var sum = 0.0;
  var count = 0;
  for (var y = top; y < bottom; y += stepY) {
    for (var x = left; x < right; x += stepX) {
      if (bgra) {
        final i = y * bytesPerRow + x * 4;
        if (i + 2 >= bytes.length) continue;
        sum += 0.114 * bytes[i] + 0.587 * bytes[i + 1] + 0.299 * bytes[i + 2];
      } else {
        final i = y * bytesPerRow + x;
        if (i >= bytes.length) continue;
        sum += bytes[i];
      }
      count++;
    }
  }
  return count == 0 ? 128 : sum / count;
}
