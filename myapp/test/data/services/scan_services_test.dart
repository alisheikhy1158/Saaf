// Covers: architecture §1.3 (every plugin behind an interface, fakes for Chrome),
// PRV-1 (private photo storage), store-compliance §1 (permission mapping)
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/file_photo_store.dart';
import 'package:saaf/data/services/plugin_camera_service.dart';
import 'package:saaf/data/services/plugin_permission_service.dart';
import 'package:saaf/data/services/plugin_photo_picker.dart';
import 'package:saaf/data/services/web/fake_camera_service.dart';
import 'package:saaf/data/services/web/fake_capture_quality_monitor.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/data/services/web/fake_photo_picker.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';

void main() {
  group('FakeCameraService (demo camera for Chrome and tests)', () {
    test('opens on the requested side and can flip', () async {
      final camera = FakeCameraService();
      expect((await camera.open(CameraFacing.front)).isOk, isTrue);
      expect(camera.facing, CameraFacing.front);
      expect(camera.canFlip, isTrue);
      await camera.open(CameraFacing.back);
      expect(camera.facing, CameraFacing.back);
    });

    test('capture returns a real PNG, a different colour each shot', () async {
      final camera = FakeCameraService();
      await camera.open(CameraFacing.front);
      final a = (await camera.capture()).valueOrNull!;
      final b = (await camera.capture()).valueOrNull!;
      expect(a.sublist(1, 4), [0x50, 0x4E, 0x47]);
      expect(a, isNot(b));
    });

    test('capturing before opening is a failure', () async {
      expect((await FakeCameraService().capture()).isOk, isFalse);
    });

    test('close stops the camera', () async {
      final camera = FakeCameraService();
      await camera.open(CameraFacing.front);
      await camera.close();
      expect((await camera.capture()).isOk, isFalse);
    });
  });

  group('FakePermissionService', () {
    test('starts as asked for, grants when requested', () async {
      final service = FakePermissionService(CameraPermission.denied);
      expect(await service.cameraStatus(), CameraPermission.denied);
      expect(await service.requestCamera(), CameraPermission.granted);
      expect(await service.cameraStatus(), CameraPermission.granted);
    });

    test('can be set to refuse', () async {
      final service = FakePermissionService(
        CameraPermission.denied,
        grantsOnRequest: false,
      );
      expect(await service.requestCamera(), CameraPermission.permanentlyDenied);
    });

    test('openSettings succeeds', () async {
      final service = FakePermissionService(CameraPermission.granted);
      expect(await service.openSettings(), isTrue);
    });
  });

  group('FakePhotoPicker', () {
    test('returns a demo photo', () async {
      final result = await FakePhotoPicker().pickFromGallery();
      expect(result.valueOrNull, isNotEmpty);
    });
  });

  group('FakeCaptureQualityMonitor', () {
    test('walks from "needs better light" to "ready"', () async {
      const monitor = FakeCaptureQualityMonitor(step: Duration.zero);
      final seen = await monitor.watch(FacePose.front).toList();
      expect(seen.first.isReady, isFalse);
      expect(seen.any((q) => q.advice.name == 'tooBright'), isTrue);
      expect(seen.last.isReady, isTrue);
    });

    test('works for every pose', () async {
      for (final pose in FacePose.values) {
        final seen = await const FakeCaptureQualityMonitor(
          step: Duration.zero,
        ).watch(pose).toList();
        expect(seen.last.isReady, isTrue, reason: '$pose');
      }
    });
  });

  group('photo stores', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    Future<void> storeContract(
      String name,
      Future<dynamic> Function() make,
    ) async {
      test('$name: save, load and delete a scan', () async {
        final store = await make();
        final saved =
            (await store.save(
                  scanId: 'scan-1',
                  pose: FacePose.left,
                  bytes: bytes,
                )).valueOrNull
                as StoredPhoto;
        expect(saved.scanId, 'scan-1');
        expect(saved.pose, FacePose.left);
        expect((await store.load(saved)).valueOrNull, bytes);

        expect((await store.deleteScan('scan-1')).isOk, isTrue);
        expect((await store.load(saved)).isOk, isFalse);
      });

      test('$name: saving again replaces the photo', () async {
        final store = await make();
        await store.save(scanId: 's', pose: FacePose.front, bytes: bytes);
        final second =
            (await store.save(
                  scanId: 's',
                  pose: FacePose.front,
                  bytes: Uint8List.fromList([9]),
                )).valueOrNull
                as StoredPhoto;
        expect((await store.load(second)).valueOrNull, [9]);
      });

      test('$name: deleting a scan that does not exist is fine', () async {
        final store = await make();
        expect((await store.deleteScan('nope')).isOk, isTrue);
      });

      test('$name: scans are kept apart', () async {
        final store = await make();
        final a =
            (await store.save(
                  scanId: 'a',
                  pose: FacePose.front,
                  bytes: bytes,
                )).valueOrNull
                as StoredPhoto;
        await store.save(scanId: 'b', pose: FacePose.front, bytes: bytes);
        await store.deleteScan('b');
        expect((await store.load(a)).valueOrNull, bytes);
      });
    }

    storeContract('InMemoryPhotoStore', () async => InMemoryPhotoStore());

    late Directory temp;
    setUp(
      () async => temp = await Directory.systemTemp.createTemp('saaf_test'),
    );
    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    group('FilePhotoStore', () {
      test('writes under scans/<id>/<pose>.jpg in the given folder', () async {
        final store = FilePhotoStore(root: () async => temp);
        final saved = (await store.save(
          scanId: 'scan-7',
          pose: FacePose.right,
          bytes: bytes,
        )).valueOrNull!;
        expect(saved.reference, 'scans/scan-7/right.jpg');
        expect(
          File('${temp.path}/scans/scan-7/right.jpg').readAsBytesSync(),
          bytes,
        );
      });

      test('deleteScan removes the whole folder', () async {
        final store = FilePhotoStore(root: () async => temp);
        await store.save(scanId: 'x', pose: FacePose.front, bytes: bytes);
        await store.deleteScan('x');
        expect(Directory('${temp.path}/scans/x').existsSync(), isFalse);
      });

      test('refuses a scan id that could escape the folder', () async {
        final store = FilePhotoStore(root: () async => temp);
        for (final bad in ['../evil', 'a/b', r'a\b', '', '.']) {
          final result = await store.save(
            scanId: bad,
            pose: FacePose.front,
            bytes: bytes,
          );
          expect(
            result.failureOrNull,
            const ValidationFailure('scanId'),
            reason: bad,
          );
        }
        expect(
          (await store.deleteScan('../evil')).failureOrNull,
          const ValidationFailure('scanId'),
        );
        expect(Directory('${temp.parent.path}/evil').existsSync(), isFalse);
      });

      test('a filesystem error becomes StorageFailure', () async {
        final store = FilePhotoStore(root: () async => temp);
        // A file named "scans" makes creating the scans folder fail.
        File('${temp.path}/scans').writeAsStringSync('in the way');
        final result = await store.save(
          scanId: 's',
          pose: FacePose.front,
          bytes: bytes,
        );
        expect(result.failureOrNull, const StorageFailure());
      });

      storeContract(
        'FilePhotoStore',
        () async => FilePhotoStore(root: () async => temp),
      );
    });
  });

  group('cameraPermissionFromStatus', () {
    const table = <PermissionStatus, CameraPermission>{
      PermissionStatus.granted: CameraPermission.granted,
      PermissionStatus.limited: CameraPermission.granted,
      PermissionStatus.denied: CameraPermission.denied,
      PermissionStatus.provisional: CameraPermission.denied,
      PermissionStatus.permanentlyDenied: CameraPermission.permanentlyDenied,
      PermissionStatus.restricted: CameraPermission.permanentlyDenied,
    };
    table.forEach((status, expected) {
      test('$status → $expected', () {
        expect(cameraPermissionFromStatus(status), expected);
      });
    });
  });

  group('cameraFailureFromCode', () {
    test('refused or restricted access is PermissionDenied', () {
      for (final code in [
        'CameraAccessDenied',
        'CameraAccessDeniedWithoutPrompt',
        'CameraAccessRestricted',
      ]) {
        expect(
          cameraFailureFromCode(code),
          const PermissionDenied(),
          reason: code,
        );
      }
    });

    test('anything else is an UnknownFailure carrying only the code', () {
      expect(
        cameraFailureFromCode('cameraNotFound'),
        const UnknownFailure('cameraNotFound'),
      );
    });
  });

  group('PluginPhotoPicker', () {
    test('returns the chosen image bytes', () async {
      final picker = PluginPhotoPicker(
        pick: () async => XFile.fromData(Uint8List.fromList([5, 6])),
      );
      expect((await picker.pickFromGallery()).valueOrNull, [5, 6]);
    });

    test('cancelling gives Ok(null)', () async {
      final picker = PluginPhotoPicker(pick: () async => null);
      final result = await picker.pickFromGallery();
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a picker error becomes a failure, not an exception', () async {
      final picker = PluginPhotoPicker(pick: () async => throw StateError('x'));
      expect((await picker.pickFromGallery()).failureOrNull, isA<Failure>());
    });
  });
}
