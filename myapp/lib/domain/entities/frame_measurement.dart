/// One face found in a camera frame, in the upright picture (0–1 across and
/// down). Produced by the face detector on the phone; the rules that judge it
/// are pure Dart (see `analyse_frame.dart`).
class FaceObservation {
  const FaceObservation({
    required this.centerX,
    required this.centerY,
    required this.widthFraction,
    required this.yawDegrees,
    required this.rollDegrees,
  });

  /// Where the middle of the face is: 0 = left/top edge, 1 = right/bottom edge.
  final double centerX;
  final double centerY;

  /// How much of the picture's width the face takes up.
  final double widthFraction;

  /// Head turn: positive when the person turns to THEIR left (so their left
  /// cheek shows), negative to their right. Around 0 when facing the camera.
  final double yawDegrees;

  /// Head tilt towards a shoulder.
  final double rollDegrees;
}

/// What the camera sees in one frame.
class FrameMeasurement {
  const FrameMeasurement({required this.brightness, this.faces = const []});

  /// Average brightness, 0 (black) to 255 (white), of the face when there is
  /// one, otherwise of the whole picture.
  final double brightness;

  final List<FaceObservation> faces;
}
