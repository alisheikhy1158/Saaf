import 'dart:typed_data';

import 'package:saaf/domain/entities/face_pose.dart';

/// One photo of a scan, held in memory until the scan is finished and saved to
/// the phone's private storage (it is never sent anywhere, PRV-2).
class ScanPhoto {
  const ScanPhoto({
    required this.pose,
    required this.bytes,
    required this.capturedAt,
  });

  final FacePose pose;
  final Uint8List bytes;
  final DateTime capturedAt;
}
