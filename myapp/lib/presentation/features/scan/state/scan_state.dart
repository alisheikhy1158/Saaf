import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/photo_check.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/entities/scan_session.dart';

/// Where the scan screen is in its flow.
enum ScanPhase {
  /// Looking at the camera permission.
  checking,

  /// Our own explanation sheet, shown before the system dialog.
  needsRationale,

  /// Refused once: explain and let the user try again.
  denied,

  /// Refused for good: only the phone's settings can help.
  needsSettings,

  /// Starting the camera.
  starting,

  /// Camera running, ready to take the current pose.
  live,

  /// Looking at a photo just taken: retake or keep.
  reviewing,

  /// Saving the three photos.
  saving,

  /// Saved; the screen moves on to the results.
  done,

  /// The camera could not start.
  failed,
}

const Object _keep = Object();

class ScanState {
  const ScanState({
    required this.phase,
    required this.session,
    this.pose = FacePose.front,
    this.quality = CaptureQuality.initial,
    this.facing = CameraFacing.front,
    this.canFlip = false,
    this.countdown,
    this.fillLight = false,
    this.failure,
    this.reviewPhoto,
    this.photoCheck,
  });

  factory ScanState.initial(ScanSession session) =>
      ScanState(phase: ScanPhase.checking, session: session);

  final ScanPhase phase;
  final ScanSession session;

  /// The pose being taken (or reviewed).
  final FacePose pose;
  final CaptureQuality quality;
  final CameraFacing facing;
  final bool canFlip;

  /// Seconds left before the photo is taken by itself; null when not counting.
  final int? countdown;

  /// The screen-light option (top-right sun button).
  final bool fillLight;

  /// The last thing that went wrong, for a message on screen.
  final Failure? failure;

  /// The photo shown in the review state.
  final ScanPhoto? reviewPhoto;

  /// What the check of [reviewPhoto] found; null while it is still checking.
  final PhotoCheck? photoCheck;

  /// The phone is really checking the camera picture and it is not good enough
  /// yet, so the shutter waits (the 2-second auto-capture also needs it).
  bool get shutterLocked => quality.assessed && !quality.isReady;

  ScanState copyWith({
    ScanPhase? phase,
    ScanSession? session,
    FacePose? pose,
    CaptureQuality? quality,
    CameraFacing? facing,
    bool? canFlip,
    Object? countdown = _keep,
    bool? fillLight,
    Object? failure = _keep,
    Object? reviewPhoto = _keep,
    Object? photoCheck = _keep,
  }) => ScanState(
    phase: phase ?? this.phase,
    session: session ?? this.session,
    pose: pose ?? this.pose,
    quality: quality ?? this.quality,
    facing: facing ?? this.facing,
    canFlip: canFlip ?? this.canFlip,
    countdown: identical(countdown, _keep) ? this.countdown : countdown as int?,
    fillLight: fillLight ?? this.fillLight,
    failure: identical(failure, _keep) ? this.failure : failure as Failure?,
    reviewPhoto: identical(reviewPhoto, _keep)
        ? this.reviewPhoto
        : reviewPhoto as ScanPhoto?,
    photoCheck: identical(photoCheck, _keep)
        ? this.photoCheck
        : photoCheck as PhotoCheck?,
  );
}
