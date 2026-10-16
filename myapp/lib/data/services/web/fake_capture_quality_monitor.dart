import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';

/// Pretends to watch the camera: starts with "too bright", then light, framing
/// and steadiness come right one after another, so the whole screen can be seen
/// working in Chrome. Replaced by real image analysis later.
class FakeCaptureQualityMonitor implements CaptureQualityMonitor {
  const FakeCaptureQualityMonitor({
    this.step = const Duration(milliseconds: 900),
  });

  /// Time between one change and the next.
  final Duration step;

  @override
  Stream<CaptureQuality> watch(FacePose pose) async* {
    yield const CaptureQuality(
      lightOk: false,
      centred: false,
      steady: false,
      advice: LightAdvice.tooBright,
    );
    await Future<void>.delayed(step);
    yield const CaptureQuality(lightOk: true, centred: false, steady: false);
    await Future<void>.delayed(step);
    yield const CaptureQuality(lightOk: true, centred: true, steady: false);
    await Future<void>.delayed(step);
    yield const CaptureQuality(lightOk: true, centred: true, steady: true);
  }
}
