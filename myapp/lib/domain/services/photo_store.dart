import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';

/// The app's private photo storage: never the public gallery, excluded from
/// cloud backup unless the user turns photo backup on (PRV-1).
abstract interface class PhotoStore {
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  });

  Future<Result<Uint8List>> load(StoredPhoto photo);

  /// Deletes every photo of [scanId].
  Future<Result<void>> deleteScan(String scanId);
}
