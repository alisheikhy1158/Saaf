import 'dart:typed_data';

import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/photo_check.dart';

/// Looks at a finished photo (from the camera or the gallery) and says whether
/// it shows one clear face in the pose that was asked for. Runs on the phone;
/// the photo is never uploaded.
abstract interface class PhotoVerifier {
  Future<PhotoCheck> check(FacePose pose, Uint8List bytes);
}
