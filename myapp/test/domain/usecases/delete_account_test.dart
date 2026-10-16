// Covers: store-compliance A-1 (delete account in the app) — the account goes
// first; the photos on the phone go after; nothing is wiped if the account
// cannot be deleted
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/usecases/delete_account.dart';

import 'auth_usecases_test.dart' show RecordingAuthRepository;

void main() {
  late RecordingAuthRepository auth;
  late InMemoryPhotoStore photos;

  setUp(() {
    auth = RecordingAuthRepository();
    photos = InMemoryPhotoStore();
  });

  Future<void> save(String scanId) async {
    for (final pose in FacePose.values) {
      await photos.save(
        scanId: scanId,
        pose: pose,
        bytes: Uint8List.fromList([1]),
      );
    }
  }

  test('deletes the account and every photo of every scan', () async {
    await save('a');
    await save('b');
    final a = (await photos.save(
      scanId: 'a',
      pose: FacePose.front,
      bytes: Uint8List.fromList([1]),
    )).valueOrNull!;

    final result = await DeleteAccount(auth: auth, photos: photos)(['a', 'b']);

    expect(result.isOk, isTrue);
    expect(auth.deleteCalls, 1);
    expect((await photos.load(a)).isOk, isFalse);
  });

  test('works with no scans at all', () async {
    final result = await DeleteAccount(auth: auth, photos: photos)(const []);
    expect(result.isOk, isTrue);
    expect(auth.deleteCalls, 1);
  });

  test('if the account cannot be deleted, the photos are kept', () async {
    await save('a');
    final stored = (await photos.save(
      scanId: 'a',
      pose: FacePose.front,
      bytes: Uint8List.fromList([1]),
    )).valueOrNull!;
    auth.deleteResult = const Err(UnknownFailure('requires-recent-login'));

    final result = await DeleteAccount(auth: auth, photos: photos)(['a']);

    expect(result.failureOrNull, const UnknownFailure('requires-recent-login'));
    expect((await photos.load(stored)).isOk, isTrue);
  });

  test(
    'a photo that cannot be removed does not undo the deleted account',
    () async {
      auth.deleteResult = const Ok<void>(null);
      final result = await DeleteAccount(auth: auth, photos: _Failing())(['a']);
      expect(result.isOk, isTrue);
    },
  );

  test('an exception becomes an UnknownFailure', () async {
    final result = await DeleteAccount(auth: _Throwing(), photos: photos)([
      'a',
    ]);
    expect(result.failureOrNull, const UnknownFailure('deleteAccount'));
  });
}

class _Failing extends InMemoryPhotoStore {
  @override
  Future<Result<void>> deleteScan(String scanId) async =>
      const Err(StorageFailure());
}

class _Throwing extends RecordingAuthRepository {
  @override
  Future<Result<void>> deleteAccount() async => throw StateError('x');
}
