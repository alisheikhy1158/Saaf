import 'dart:typed_data';

import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/photo_check.dart';
import 'package:saaf/domain/services/photo_verifier.dart';

/// Accepts every photo (Chrome demos and tests, where there is no face
/// detector).
class AlwaysOkPhotoVerifier implements PhotoVerifier {
  const AlwaysOkPhotoVerifier();

  @override
  Future<PhotoCheck> check(FacePose pose, Uint8List bytes) async =>
      PhotoCheck.ok;
}
