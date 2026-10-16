import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/frame_measurement.dart';
import 'package:saaf/domain/entities/photo_check.dart';

export 'package:saaf/domain/entities/photo_check.dart';

/// Which way the head must turn for each side view. The face detector reports
/// a positive angle when the person turns to THEIR left (see
/// [FaceObservation.yawDegrees]), which shows their left cheek.
double _yawSign(FacePose pose) => pose == FacePose.left ? 1 : -1;

/// Judges live camera frames for the scan screen: light, one face, centred and
/// big enough, head turned the way this pose needs, and held still. Keeps a
/// little memory between frames for the "hold still" check.
class FrameQualityAnalyzer {
  /// Similar frames in a row before the phone counts as steady.
  static const steadyFramesNeeded = 3;

  // Light (0–255 average on the face). Deeper skin tones read darker even in
  // good light, so "too dark" starts low.
  static const double _tooDark = 55;
  static const double _tooBright = 215;

  // How big the face is in the picture.
  static const double _minWidthFront = 0.30;
  static const double _minWidthSide = 0.22;
  static const double _maxWidth = 0.88;

  // How far from the middle of the picture the face may be.
  static const double _maxOffX = 0.20;
  static const double _maxOffY = 0.22;

  // Head angles, in degrees.
  static const double _frontYaw = 12;
  static const double _frontRoll = 18;
  static const double _sideRoll = 25;
  static const double _sideMin = 18;
  static const double _sideMax = 55;

  // How much the face may move between frames and still count as still.
  static const double _stillMove = 0.03;
  static const double _stillSize = 0.06;

  FaceObservation? _previous;
  int _steadyFrames = 0;

  /// Forget the last frames (a new pose starts).
  void reset() {
    _previous = null;
    _steadyFrames = 0;
  }

  CaptureQuality analyse(FacePose pose, FrameMeasurement frame) {
    final light = frame.brightness < _tooDark
        ? LightAdvice.tooDark
        : frame.brightness > _tooBright
        ? LightAdvice.tooBright
        : LightAdvice.none;
    final lightOk = light == LightAdvice.none;

    if (frame.faces.isEmpty || frame.faces.length > 1) {
      reset();
      return CaptureQuality(
        lightOk: lightOk,
        centred: false,
        steady: false,
        poseOk: false,
        advice: light,
        assessed: true,
        faceAdvice: frame.faces.isEmpty
            ? FaceAdvice.noFace
            : FaceAdvice.severalFaces,
      );
    }

    final face = frame.faces.single;
    final minWidth = pose.isProfile ? _minWidthSide : _minWidthFront;
    final sizeAdvice = face.widthFraction < minWidth
        ? FaceAdvice.moveCloser
        : face.widthFraction > _maxWidth
        ? FaceAdvice.moveBack
        : FaceAdvice.none;
    final inMiddle =
        (face.centerX - 0.5).abs() <= _maxOffX &&
        (face.centerY - 0.5).abs() <= _maxOffY;
    final centred = sizeAdvice == FaceAdvice.none && inMiddle;
    final poseAdvice = _poseAdvice(pose, face);

    final steady = _updateSteady(face);

    return CaptureQuality(
      lightOk: lightOk,
      centred: centred,
      steady: steady,
      poseOk: poseAdvice == FaceAdvice.none,
      advice: light,
      assessed: true,
      faceAdvice: sizeAdvice != FaceAdvice.none
          ? sizeAdvice
          : !inMiddle
          ? FaceAdvice.centreFace
          : poseAdvice,
    );
  }

  FaceAdvice _poseAdvice(FacePose pose, FaceObservation face) {
    if (!pose.isProfile) {
      return face.yawDegrees.abs() <= _frontYaw &&
              face.rollDegrees.abs() <= _frontRoll
          ? FaceAdvice.none
          : FaceAdvice.lookStraight;
    }
    final turn = face.yawDegrees * _yawSign(pose);
    if (turn > _sideMax) return FaceAdvice.turnLess;
    if (turn < _sideMin) {
      return pose == FacePose.left ? FaceAdvice.turnLeft : FaceAdvice.turnRight;
    }
    return face.rollDegrees.abs() <= _sideRoll
        ? FaceAdvice.none
        : FaceAdvice.lookStraight;
  }

  bool _updateSteady(FaceObservation face) {
    final before = _previous;
    final still =
        before != null &&
        (face.centerX - before.centerX).abs() <= _stillMove &&
        (face.centerY - before.centerY).abs() <= _stillMove &&
        (face.widthFraction - before.widthFraction).abs() <= _stillSize;
    _steadyFrames = still ? _steadyFrames + 1 : 1;
    _previous = face;
    return _steadyFrames >= steadyFramesNeeded;
  }
}

/// Judges a finished photo (taken or from the gallery). Kinder than the live
/// check: the face need not be dead centre, and angles may be a little off.
PhotoCheck checkPhoto(FacePose pose, FrameMeasurement photo) {
  if (photo.faces.isEmpty) return PhotoCheck.noFace;
  if (photo.faces.length > 1) return PhotoCheck.severalFaces;
  final face = photo.faces.single;

  if (face.widthFraction < 0.12) return PhotoCheck.tooSmall;
  if (photo.brightness < 45) return PhotoCheck.tooDark;
  if (photo.brightness > 225) return PhotoCheck.tooBright;

  if (!pose.isProfile) {
    final straight =
        face.yawDegrees.abs() <= 20 && face.rollDegrees.abs() <= 25;
    return straight ? PhotoCheck.ok : PhotoCheck.wrongPose;
  }
  final turn = face.yawDegrees * _yawSign(pose);
  return turn >= 15 && turn <= 65 ? PhotoCheck.ok : PhotoCheck.wrongPose;
}
