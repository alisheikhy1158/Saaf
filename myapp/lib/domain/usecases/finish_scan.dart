import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/scan_session.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/services/photo_store.dart';

/// Saves a complete scan's three photos to private storage. If any photo cannot
/// be saved, the ones already saved are removed again.
class FinishScan {
  const FinishScan(this._store);

  final PhotoStore _store;

  Future<Result<List<StoredPhoto>>> call(ScanSession session) async {
    if (!session.isComplete) return const Err(ValidationFailure('scan'));

    final saved = <StoredPhoto>[];
    try {
      for (final photo in session.orderedPhotos) {
        final result = await _store.save(
          scanId: session.id,
          pose: photo.pose,
          bytes: photo.bytes,
        );
        final stored = result.valueOrNull;
        if (stored == null) return await _rollback(session.id);
        saved.add(stored);
      }
    } on Object {
      return _rollback(session.id);
    }
    return Ok(saved);
  }

  Future<Result<List<StoredPhoto>>> _rollback(String scanId) async {
    try {
      await _store.deleteScan(scanId);
    } on Object {
      // Nothing more can be done.
    }
    return const Err(StorageFailure());
  }
}
