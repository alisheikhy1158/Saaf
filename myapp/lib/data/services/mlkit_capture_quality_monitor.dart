import 'dart:async';
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:saaf/data/services/face_frame_conversion.dart';
import 'package:saaf/data/services/live_frame_source.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/frame_measurement.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/domain/usecases/analyse_frame.dart';

/// Really looks at the live camera (phones): a few times a second it asks ML
/// Kit's on-device face detector what it sees and judges the answer with
/// [FrameQualityAnalyzer]. Nothing leaves the phone.
///
/// If the detector fails, or no frame arrives for a while, it reports an
/// unchecked picture ([CaptureQuality.assessed] false), which frees the shutter
/// so the scan still works by hand.
class MlKitCaptureQualityMonitor implements CaptureQualityMonitor {
  MlKitCaptureQualityMonitor(this._source, {TargetPlatform? platform})
    : _platform = platform ?? defaultTargetPlatform;

  final LiveFrameSource _source;
  final TargetPlatform _platform;

  /// Frames are looked at this often (the detector is the slow part).
  static const _gap = Duration(milliseconds: 250);

  /// No analysed frame for this long means the checks are not working.
  static const _silence = Duration(seconds: 5);

  /// Before the first answer the shutter waits: nothing is known yet.
  static const _waiting = CaptureQuality(
    lightOk: false,
    centred: false,
    steady: false,
    poseOk: false,
    faceAdvice: FaceAdvice.noFace,
    assessed: true,
  );

  /// The checks are not working: unchecked, so the shutter works by hand.
  static const _unchecked = CaptureQuality(
    lightOk: false,
    centred: false,
    steady: false,
    poseOk: false,
  );

  @override
  Stream<CaptureQuality> watch(FacePose pose) {
    final analyzer = FrameQualityAnalyzer();
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        // "Accurate" is needed for a reliable head turn angle.
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      ),
    );
    StreamSubscription<LiveFrame>? frames;
    Timer? watchdog;
    var busy = false;
    var lastLook = DateTime.fromMillisecondsSinceEpoch(0);
    late final StreamController<CaptureQuality> out;

    void giveUp() {
      if (!out.isClosed) out.add(_unchecked);
    }

    void arm() {
      watchdog?.cancel();
      watchdog = Timer(_silence, giveUp);
    }

    Future<void> look(LiveFrame frame) async {
      try {
        final quality = await _analyse(detector, analyzer, pose, frame);
        if (out.isClosed) return;
        arm();
        out.add(quality);
      } on Object {
        giveUp();
      }
    }

    out = StreamController<CaptureQuality>(
      onListen: () {
        out.add(_waiting);
        arm();
        frames = _source.liveFrames().listen((frame) {
          final now = DateTime.now();
          if (busy || now.difference(lastLook) < _gap) return;
          busy = true;
          lastLook = now;
          unawaited(look(frame).whenComplete(() => busy = false));
        }, onError: (Object _) => giveUp());
      },
      onCancel: () async {
        watchdog?.cancel();
        await frames?.cancel();
        try {
          await detector.close();
        } on Object {
          // Already closed.
        }
      },
    );
    return out.stream;
  }

  Future<CaptureQuality> _analyse(
    FaceDetector detector,
    FrameQualityAnalyzer analyzer,
    FacePose pose,
    LiveFrame frame,
  ) async {
    final image = frame.image;
    final rotation = imageRotation(
      sensorOrientation: frame.sensorOrientation,
      deviceOrientation: frame.deviceOrientation,
      frontCamera: frame.front,
      platform: _platform,
    );
    if (rotation == null || image.planes.isEmpty) {
      throw StateError('unsupported-frame');
    }
    final bgra = _platform == TargetPlatform.iOS;
    final plane = image.planes.first;
    final raw = Size(image.width.toDouble(), image.height.toDouble());
    final stride = plane.bytesPerRow > 0
        ? plane.bytesPerRow
        : (bgra ? image.width * 4 : image.width);

    final faces = await detector.processImage(
      InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: raw,
          rotation: rotation,
          format: bgra ? InputImageFormat.bgra8888 : InputImageFormat.nv21,
          bytesPerRow: stride,
        ),
      ),
    );

    final upright = uprightSize(raw, rotation);
    // The iOS front camera hands over a mirror image of the person.
    final mirrored = bgra && frame.front;
    return analyzer.analyse(
      pose,
      FrameMeasurement(
        brightness: meanBrightness(
          bytes: plane.bytes,
          width: image.width,
          height: image.height,
          bytesPerRow: stride,
          bgra: bgra,
        ),
        faces: [
          for (final face in faces)
            observationFrom(
              box: face.boundingBox,
              yaw: face.headEulerAngleY,
              roll: face.headEulerAngleZ,
              upright: upright,
              mirrored: mirrored,
            ),
        ],
      ),
    );
  }
}
