import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/photo_check.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/entities/scan_session.dart';
import 'package:saaf/domain/usecases/camera_access.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

part 'scan_controller.g.dart';

/// Runs the three-pose face scan (front, left, right): permission, camera,
/// quality hints, the 2-second auto-capture, review and saving.
@riverpod
class ScanController extends _$ScanController {
  /// Seconds the face must stay "ready" before the photo is taken by itself.
  static const int countdownSeconds = 2;

  StreamSubscription<CaptureQuality>? _quality;
  Timer? _timer;
  bool _capturing = false;
  bool _cameraOpen = false;

  @override
  ScanState build() {
    final camera = ref.read(cameraServiceProvider);
    ref.onDispose(() {
      unawaited(_quality?.cancel());
      _timer?.cancel();
      unawaited(camera.close());
    });

    final now = ref.read(clockProvider).now();
    Future.microtask(_check);
    return ScanState.initial(
      ScanSession.start(
        id: 'scan-${now.millisecondsSinceEpoch}',
        startedAt: now,
      ),
    );
  }

  // ── Permission and camera ────────────────────────────────────────────────

  Future<void> _check() async {
    final outcome = await ref.read(cameraAccessProvider).check();
    if (!ref.mounted) return;
    await _apply(outcome);
  }

  Future<void> _apply(CameraAccessOutcome outcome) async {
    switch (outcome) {
      case CameraAccessOutcome.granted:
        await _openCamera();
      case CameraAccessOutcome.needsRationale:
        state = state.copyWith(phase: ScanPhase.needsRationale);
      case CameraAccessOutcome.denied:
        state = state.copyWith(phase: ScanPhase.denied);
      case CameraAccessOutcome.needsSettings:
        state = state.copyWith(phase: ScanPhase.needsSettings);
    }
  }

  /// "Continue" on our explanation sheet: now the system may ask.
  Future<void> continueFromRationale() async {
    state = state.copyWith(phase: ScanPhase.checking);
    final outcome = await ref.read(cameraAccessProvider).request();
    if (!ref.mounted) return;
    await _apply(outcome);
  }

  /// Asks the phone to open this app's settings page.
  Future<void> openSettings() => ref.read(cameraAccessProvider).openSettings();

  /// "Try again" (after settings, after a camera error, after "not now").
  Future<void> retry() async {
    state = state.copyWith(phase: ScanPhase.checking, failure: null);
    await _check();
  }

  Future<void> _openCamera() async {
    state = state.copyWith(phase: ScanPhase.starting, failure: null);
    final camera = ref.read(cameraServiceProvider);
    final result = await camera.open(state.facing);
    if (!ref.mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      _cameraOpen = false;
      state = state.copyWith(
        phase: failure is PermissionDenied
            ? ScanPhase.needsSettings
            : ScanPhase.failed,
        failure: failure,
      );
      return;
    }
    _cameraOpen = true;
    state = state.copyWith(phase: ScanPhase.live, canFlip: camera.canFlip);
    _watchQuality();
  }

  /// Back to the live camera, or through the permission check when it was never
  /// started (the user is working from gallery photos).
  Future<void> _resume() async {
    if (_cameraOpen) {
      state = state.copyWith(
        phase: ScanPhase.live,
        reviewPhoto: null,
        photoCheck: null,
        failure: null,
      );
      _watchQuality();
    } else {
      state = state.copyWith(
        reviewPhoto: null,
        photoCheck: null,
        failure: null,
      );
      await _check();
    }
  }

  // ── Quality and auto-capture ─────────────────────────────────────────────

  void _watchQuality() {
    _stopWatching();
    state = state.copyWith(quality: CaptureQuality.initial, countdown: null);
    _quality = ref
        .read(captureQualityMonitorProvider)
        .watch(state.pose)
        .listen(_onQuality);
  }

  void _stopWatching() {
    unawaited(_quality?.cancel());
    _quality = null;
    _cancelCountdown();
  }

  void _onQuality(CaptureQuality quality) {
    if (state.phase != ScanPhase.live) return;
    state = state.copyWith(quality: quality);
    if (!quality.isReady) {
      _cancelCountdown();
      return;
    }
    if (_timer != null) return;
    state = state.copyWith(countdown: countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = (state.countdown ?? 1) - 1;
      if (remaining > 0) {
        state = state.copyWith(countdown: remaining);
      } else {
        _cancelCountdown();
        unawaited(capture());
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    _timer = null;
    if (state.countdown != null) state = state.copyWith(countdown: null);
  }

  // ── Taking, keeping and retaking ─────────────────────────────────────────

  /// The shutter. With the demo monitor it works at once; when the phone is
  /// really checking the picture it waits until the checks pass (the screen
  /// also disables the button).
  Future<void> capture() async {
    if (state.phase != ScanPhase.live || _capturing) return;
    if (state.shutterLocked) return;
    _capturing = true;
    _cancelCountdown();
    final result = await ref.read(capturePhotoProvider)(state.pose);
    _capturing = false;
    if (!ref.mounted) return;

    final photo = result.valueOrNull;
    if (photo == null) {
      state = state.copyWith(failure: result.failureOrNull);
      return;
    }
    _review(photo);
  }

  /// "Choose from gallery". Allowed without the camera (the app stays usable).
  Future<void> pickFromGallery() async {
    const allowed = {
      ScanPhase.live,
      ScanPhase.needsRationale,
      ScanPhase.denied,
      ScanPhase.needsSettings,
      ScanPhase.failed,
    };
    if (!allowed.contains(state.phase)) return;
    final result = await ref.read(pickPhotoProvider)(state.pose);
    if (!ref.mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      state = state.copyWith(failure: failure);
      return;
    }
    final photo = result.valueOrNull;
    if (photo == null) return; // cancelled
    _review(photo);
  }

  void _review(ScanPhoto photo) {
    _stopWatching();
    state = state.copyWith(
      phase: ScanPhase.reviewing,
      session: state.session.withPhoto(photo),
      pose: photo.pose,
      reviewPhoto: photo,
      photoCheck: null,
      failure: null,
    );
    unawaited(_verify(photo));
  }

  /// Looks at the photo for a clear face in the right pose and records what it
  /// found. The photo can still be kept either way; the screen says what is
  /// wrong and recommends a retake.
  Future<void> _verify(ScanPhoto photo) async {
    PhotoCheck verdict;
    try {
      verdict = await ref
          .read(photoVerifierProvider)
          .check(photo.pose, photo.bytes);
    } on Object {
      verdict = PhotoCheck.unavailable;
    }
    if (!ref.mounted || !identical(state.reviewPhoto, photo)) return;
    state = state.copyWith(photoCheck: verdict);
  }

  /// Throws the photo away and shows the camera again.
  Future<void> retake() async {
    if (state.phase != ScanPhase.reviewing) return;
    state = state.copyWith(session: state.session.withoutPose(state.pose));
    await _resume();
  }

  /// Keeps the photo: on to the next missing pose, or save when all three exist.
  Future<void> accept() async {
    if (state.phase != ScanPhase.reviewing) return;
    final next = state.session.nextMissing;
    if (next == null) {
      await _finish();
      return;
    }
    state = state.copyWith(pose: next);
    await _resume();
  }

  /// A tap on the pose stepper: a finished pose is shown again for review, the
  /// next missing one opens the camera. Anything else is ignored.
  void selectPose(FacePose pose) {
    if (state.phase != ScanPhase.live && state.phase != ScanPhase.reviewing) {
      return;
    }
    final photo = state.session.photos[pose];
    if (photo != null) {
      _review(photo);
    } else if (pose == state.session.nextMissing && pose != state.pose) {
      state = state.copyWith(pose: pose);
      unawaited(_resume());
    }
  }

  Future<void> _finish() async {
    state = state.copyWith(phase: ScanPhase.saving, failure: null);
    final session = state.session;
    final result = await ref.read(finishScanProvider)(session);
    if (!ref.mounted) return;

    final photos = result.valueOrNull;
    if (photos == null) {
      state = state.copyWith(
        phase: ScanPhase.reviewing,
        failure: result.failureOrNull,
      );
      return;
    }
    final scan = CompletedScan(
      id: session.id,
      takenAt: session.startedAt,
      photos: photos,
    );
    ref.read(completedScanProvider.notifier).set(scan);
    ref.read(scanHistoryProvider.notifier).add(scan);
    state = state.copyWith(phase: ScanPhase.done);
  }

  // ── Camera controls ──────────────────────────────────────────────────────

  Future<void> flip() async {
    if (state.phase != ScanPhase.live) return;
    _stopWatching();
    state = state.copyWith(facing: state.facing.flipped);
    await _openCamera();
  }

  void toggleFillLight() => state = state.copyWith(fillLight: !state.fillLight);

  void toggleGhost() => state = state.copyWith(ghost: !state.ghost);
}
