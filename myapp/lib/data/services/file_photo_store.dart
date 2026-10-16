import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/services/photo_store.dart';

/// Saves photos as files in the app's private folder, `scans/<scanId>/<pose>.jpg`
/// (never the public gallery, PRV-1). Phones only; Chrome uses `InMemoryPhotoStore`.
class FilePhotoStore implements PhotoStore {
  /// [root] is the folder everything goes under; tests pass a temporary one.
  FilePhotoStore({Future<Directory> Function()? root})
    : _root = root ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _root;

  /// A scan id becomes a folder name, so only plain characters are allowed
  /// (nothing that could climb out of the folder, SEC-8).
  static final RegExp _safeId = RegExp(r'^[A-Za-z0-9_-]+$');

  static String _relative(String scanId, FacePose pose) =>
      'scans/$scanId/${pose.name}.jpg';

  Future<File> _file(String scanId, FacePose pose) async {
    final root = await _root();
    return File('${root.path}/${_relative(scanId, pose)}');
  }

  @override
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  }) async {
    if (!_safeId.hasMatch(scanId)) {
      return const Err(ValidationFailure('scanId'));
    }
    try {
      final file = await _file(scanId, pose);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      return Ok(
        StoredPhoto(
          scanId: scanId,
          pose: pose,
          reference: _relative(scanId, pose),
        ),
      );
    } on Object {
      return const Err(StorageFailure());
    }
  }

  @override
  Future<Result<Uint8List>> load(StoredPhoto photo) async {
    if (!_safeId.hasMatch(photo.scanId)) {
      return const Err(ValidationFailure('scanId'));
    }
    try {
      // The path is rebuilt from the id and pose, never taken from `reference`.
      final file = await _file(photo.scanId, photo.pose);
      if (!await file.exists()) return const Err(StorageFailure());
      return Ok(await file.readAsBytes());
    } on Object {
      return const Err(StorageFailure());
    }
  }

  @override
  Future<Result<void>> deleteScan(String scanId) async {
    if (!_safeId.hasMatch(scanId)) {
      return const Err(ValidationFailure('scanId'));
    }
    try {
      final root = await _root();
      final folder = Directory('${root.path}/scans/$scanId');
      if (await folder.exists()) await folder.delete(recursive: true);
      return const Ok<void>(null);
    } on Object {
      return const Err(StorageFailure());
    }
  }
}
