/// The verdict on a finished photo (taken or picked from the gallery).
enum PhotoCheck {
  /// One clear face, in the right pose, with usable light.
  ok,

  /// No face could be found.
  noFace,

  /// More than one face.
  severalFaces,

  /// A face, but not the pose that was asked for (e.g. facing the camera for
  /// the left cheek).
  wrongPose,

  /// The face is too small in the picture to read the skin.
  tooSmall,

  tooDark,
  tooBright,

  /// The check could not run (no detector on this device); the photo is kept
  /// without a verdict.
  unavailable,
}

extension PhotoCheckAdvice on PhotoCheck {
  /// The photo has a problem worth a retake ([PhotoCheck.unavailable] and
  /// [PhotoCheck.ok] do not).
  bool get needsRetake =>
      this != PhotoCheck.ok && this != PhotoCheck.unavailable;
}
