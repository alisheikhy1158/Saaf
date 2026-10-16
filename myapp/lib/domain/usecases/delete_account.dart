import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';
import 'package:saaf/domain/services/photo_store.dart';

/// "Delete my account" (store requirement A-1). The account is deleted first, so
/// if the backend refuses (for example the login is too old) nothing on the
/// phone is touched. Then every scan's photos are removed from private storage,
/// best effort: a photo that cannot be removed does not undo the deletion. The
/// caller clears the remaining on-device data (answers, routine, history).
class DeleteAccount {
  const DeleteAccount({
    required AuthRepository auth,
    required PhotoStore photos,
  }) : _auth = auth,
       _photos = photos;

  final AuthRepository _auth;
  final PhotoStore _photos;

  /// [scanIds] are the scans whose photos are on the phone.
  Future<Result<void>> call(List<String> scanIds) async {
    try {
      final deleted = await _auth.deleteAccount();
      if (!deleted.isOk) return deleted;
    } on Object {
      return const Err(UnknownFailure('deleteAccount'));
    }

    for (final id in scanIds) {
      try {
        await _photos.deleteScan(id);
      } on Object {
        // Best effort: the account is already gone.
      }
    }
    return const Ok<void>(null);
  }
}
