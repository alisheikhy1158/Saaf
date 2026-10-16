import 'dart:typed_data';

import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/services/photo_store.dart';

/// Keeps photos in memory (lost when the app closes). Used in Chrome and tests;
/// phones use `FilePhotoStore`.
class InMemoryPhotoStore implements PhotoStore {
  final Map<String, Uint8List> _files = {};

  static String _reference(String scanId, FacePose pose) =>
      'scans/$scanId/${pose.name}.jpg';

  @override
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  }) async {
    final reference = _reference(scanId, pose);
    _files[reference] = Uint8List.fromList(bytes);
    return Ok(StoredPhoto(scanId: scanId, pose: pose, reference: reference));
  }

  @override
  Future<Result<Uint8List>> load(StoredPhoto photo) async {
    final bytes = _files[_reference(photo.scanId, photo.pose)];
    return bytes == null ? const Err(StorageFailure()) : Ok(bytes);
  }

  @override
  Future<Result<void>> deleteScan(String scanId) async {
    _files.removeWhere((key, _) => key.startsWith('scans/$scanId/'));
    return const Ok<void>(null);
  }
}
