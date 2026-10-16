import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';

/// Watches the camera view and reports whether it is good enough to shoot:
/// light, face centred, phone steady. The real implementation needs on-device
/// image analysis (later); until then a fake drives the screen.
abstract interface class CaptureQualityMonitor {
  Stream<CaptureQuality> watch(FacePose pose);
}
