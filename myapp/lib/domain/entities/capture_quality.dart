enum LightAdvice { none, tooDark, tooBright }

/// What to tell the user about their face and head in the frame.
enum FaceAdvice {
  none,
  noFace,
  severalFaces,
  moveCloser,
  moveBack,
  centreFace,
  lookStraight,

  /// Show the left cheek: turn the head to the left.
  turnLeft,

  /// Show the right cheek: turn the head to the right.
  turnRight,

  /// Turned past the side view.
  turnLess,
}

/// How good the current camera view is for a skin photo: the chips on the scan
/// screen ("Good light", "Face centred", "Right angle", "Hold still").
class CaptureQuality {
  const CaptureQuality({
    required this.lightOk,
    required this.centred,
    required this.steady,
    this.poseOk = true,
    this.advice = LightAdvice.none,
    this.faceAdvice = FaceAdvice.none,
    this.assessed = false,
  });

  /// Nothing known yet.
  static const CaptureQuality initial = CaptureQuality(
    lightOk: false,
    centred: false,
    steady: false,
    poseOk: false,
  );

  final bool lightOk;
  final bool centred;
  final bool steady;

  /// The head is turned the way this photo needs (straight, or a side view).
  final bool poseOk;

  /// What to tell the user when the light is not ok ("Move to softer light").
  final LightAdvice advice;

  /// What to tell the user about their face or head.
  final FaceAdvice faceAdvice;

  /// True when these values come from really looking at the camera picture
  /// (phones). Only then does a "not ready" lock the shutter; the demo monitor
  /// in Chrome and tests leaves it false so the button always works.
  final bool assessed;

  /// Everything is fine: the photo can be taken.
  bool get isReady => lightOk && centred && poseOk && steady;

  CaptureQuality copyWith({
    bool? lightOk,
    bool? centred,
    bool? steady,
    bool? poseOk,
    LightAdvice? advice,
    FaceAdvice? faceAdvice,
    bool? assessed,
  }) => CaptureQuality(
    lightOk: lightOk ?? this.lightOk,
    centred: centred ?? this.centred,
    steady: steady ?? this.steady,
    poseOk: poseOk ?? this.poseOk,
    advice: advice ?? this.advice,
    faceAdvice: faceAdvice ?? this.faceAdvice,
    assessed: assessed ?? this.assessed,
  );

  @override
  bool operator ==(Object other) =>
      other is CaptureQuality &&
      other.lightOk == lightOk &&
      other.centred == centred &&
      other.steady == steady &&
      other.poseOk == poseOk &&
      other.advice == advice &&
      other.faceAdvice == faceAdvice &&
      other.assessed == assessed;

  @override
  int get hashCode => Object.hash(
    lightOk,
    centred,
    steady,
    poseOk,
    advice,
    faceAdvice,
    assessed,
  );
}
