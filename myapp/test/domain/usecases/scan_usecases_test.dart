// Covers: store-compliance §1 (permission flow: check → rationale → request →
// denied/permanently denied → settings; app stays usable without the camera),
// PRV-1 (photos only in private storage), PERF-3, architecture §3.10
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/entities/scan_session.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/services/camera_service.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/permission_service.dart';
import 'package:saaf/domain/services/photo_picker.dart';
import 'package:saaf/domain/services/photo_store.dart';
import 'package:saaf/domain/usecases/camera_access.dart';
import 'package:saaf/domain/usecases/capture_photo.dart';
import 'package:saaf/domain/usecases/finish_scan.dart';
import 'package:saaf/domain/usecases/pick_photo.dart';

class FakePermissionService implements PermissionService {
  FakePermissionService(this.status, {this.afterRequest});
  CameraPermission status;
  CameraPermission? afterRequest;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<CameraPermission> cameraStatus() async => status;

  @override
  Future<CameraPermission> requestCamera() async {
    requests++;
    return status = afterRequest ?? status;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class FakeCamera implements CameraService {
  Result<Uint8List> shot = Ok(Uint8List.fromList([1, 2, 3]));
  Result<void> openResult = const Ok(null);
  CameraFacing? opened;
  int closes = 0;

  @override
  Future<Result<void>> open(CameraFacing facing) async {
    opened = facing;
    return openResult;
  }

  @override
  Future<Result<Uint8List>> capture() async => shot;

  @override
  Future<void> close() async => closes++;

  @override
  bool get canFlip => true;
}

class FakePicker implements PhotoPicker {
  Result<Uint8List?> result = const Ok(null);
  @override
  Future<Result<Uint8List?>> pickFromGallery() async => result;
}

class FakeClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 10, 17, 9, 30);
}

class FakeStore implements PhotoStore {
  final saved = <(String, FacePose, Uint8List)>[];
  final deleted = <String>[];
  Object? failWith;

  @override
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  }) async {
    if (failWith != null) throw failWith!;
    saved.add((scanId, pose, bytes));
    return Ok(
      StoredPhoto(
        scanId: scanId,
        pose: pose,
        reference: '$scanId/${pose.name}',
      ),
    );
  }

  @override
  Future<Result<Uint8List>> load(StoredPhoto photo) async =>
      const Err(StorageFailure());

  @override
  Future<Result<void>> deleteScan(String scanId) async {
    deleted.add(scanId);
    return const Ok(null);
  }
}

void main() {
  group('CameraAccess (permission flow)', () {
    test('already granted: go straight to the camera', () async {
      final access = CameraAccess(
        FakePermissionService(CameraPermission.granted),
      );
      expect(await access.check(), CameraAccessOutcome.granted);
    });

    test('not yet allowed: the screen must show the rationale first', () async {
      final access = CameraAccess(
        FakePermissionService(CameraPermission.denied),
      );
      expect(await access.check(), CameraAccessOutcome.needsRationale);
    });

    test(
      'permanently denied: the only way forward is the phone settings',
      () async {
        final access = CameraAccess(
          FakePermissionService(CameraPermission.permanentlyDenied),
        );
        expect(await access.check(), CameraAccessOutcome.needsSettings);
      },
    );

    test('requesting after the rationale: allowed', () async {
      final service = FakePermissionService(
        CameraPermission.denied,
        afterRequest: CameraPermission.granted,
      );
      expect(
        await CameraAccess(service).request(),
        CameraAccessOutcome.granted,
      );
      expect(service.requests, 1);
    });

    test('requesting: refused once → can ask again later', () async {
      final service = FakePermissionService(
        CameraPermission.denied,
        afterRequest: CameraPermission.denied,
      );
      expect(await CameraAccess(service).request(), CameraAccessOutcome.denied);
    });

    test('requesting: refused for good → settings', () async {
      final service = FakePermissionService(
        CameraPermission.denied,
        afterRequest: CameraPermission.permanentlyDenied,
      );
      expect(
        await CameraAccess(service).request(),
        CameraAccessOutcome.needsSettings,
      );
    });

    test('never asks the system again when it is already granted', () async {
      final service = FakePermissionService(CameraPermission.granted);
      await CameraAccess(service).request();
      expect(service.requests, 0);
    });

    test('openSettings forwards to the permission service', () async {
      final service = FakePermissionService(CameraPermission.permanentlyDenied);
      expect(await CameraAccess(service).openSettings(), isTrue);
      expect(service.settingsOpened, 1);
    });
  });

  group('CapturePhoto', () {
    final camera = FakeCamera();
    final useCase = CapturePhoto(camera: camera, clock: FakeClock());

    test('turns a camera shot into a ScanPhoto for the pose', () async {
      final result = await useCase(FacePose.left);
      final photo = result.valueOrNull!;
      expect(photo.pose, FacePose.left);
      expect(photo.bytes, [1, 2, 3]);
      expect(photo.capturedAt, DateTime.utc(2026, 10, 17, 9, 30));
    });

    test('an empty image is a failure, not a blank photo', () async {
      camera.shot = Ok(Uint8List(0));
      final result = await useCase(FacePose.front);
      expect(result.failureOrNull, const UnknownFailure('empty-photo'));
      camera.shot = Ok(Uint8List.fromList([1]));
    });

    test('a camera failure passes through', () async {
      camera.shot = const Err(PermissionDenied());
      expect(
        (await useCase(FacePose.front)).failureOrNull,
        const PermissionDenied(),
      );
    });
  });

  group('PickPhoto (system gallery picker, no permission needed)', () {
    final picker = FakePicker();
    final useCase = PickPhoto(picker: picker, clock: FakeClock());

    test('wraps the chosen image as a ScanPhoto', () async {
      picker.result = Ok(Uint8List.fromList([9, 9]));
      final photo = (await useCase(FacePose.right)).valueOrNull;
      expect(photo?.pose, FacePose.right);
      expect(photo?.bytes, [9, 9]);
    });

    test('cancelling the picker is not an error: no photo', () async {
      picker.result = const Ok(null);
      final result = await useCase(FacePose.front);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('a picker failure passes through', () async {
      picker.result = const Err(StorageFailure());
      expect(
        (await useCase(FacePose.front)).failureOrNull,
        const StorageFailure(),
      );
    });

    test('an empty file is rejected', () async {
      picker.result = Ok(Uint8List(0));
      expect(
        (await useCase(FacePose.front)).failureOrNull,
        const UnknownFailure('empty-photo'),
      );
    });
  });

  group('FinishScan (saves the three photos privately)', () {
    ScanSession full() {
      var s = ScanSession.start(
        id: 'scan-9',
        startedAt: DateTime.utc(2026, 10, 17),
      );
      for (final pose in FacePose.values) {
        s = s.withPhoto(
          ScanPhoto(
            pose: pose,
            bytes: Uint8List.fromList([pose.number]),
            capturedAt: DateTime.utc(2026, 10, 17),
          ),
        );
      }
      return s;
    }

    test('stores every photo under the scan id', () async {
      final store = FakeStore();
      final result = await FinishScan(store)(full());
      expect(result.isOk, isTrue);
      expect(store.saved.map((e) => e.$1).toSet(), {'scan-9'});
      expect(store.saved.map((e) => e.$2), FacePose.values);
      expect(result.valueOrNull?.length, 3);
    });

    test('refuses an incomplete scan without storing anything', () async {
      final store = FakeStore();
      final partial = full().withoutPose(FacePose.left);
      final result = await FinishScan(store)(partial);
      expect(result.failureOrNull, const ValidationFailure('scan'));
      expect(store.saved, isEmpty);
    });

    test('a storage error removes what was already saved', () async {
      final store = FakeStore();
      // Fail on the second photo.
      var calls = 0;
      final flaky = _FlakyStore(store, failOn: 2, onCall: () => calls++);
      final result = await FinishScan(flaky)(full());
      expect(result.failureOrNull, const StorageFailure());
      expect(store.deleted, ['scan-9']);
    });
  });

  group('CaptureQualityMonitor contract', () {
    test('a monitor can be a plain stream of CaptureQuality', () async {
      final monitor = _ScriptedMonitor([
        CaptureQuality.initial,
        const CaptureQuality(lightOk: true, centred: true, steady: true),
      ]);
      final seen = await monitor.watch(FacePose.front).toList();
      expect(seen.last.isReady, isTrue);
    });
  });
}

class _FlakyStore implements PhotoStore {
  _FlakyStore(this.inner, {required this.failOn, required this.onCall});
  final FakeStore inner;
  final int failOn;
  final void Function() onCall;
  int calls = 0;

  @override
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  }) {
    calls++;
    onCall();
    if (calls == failOn) return Future.value(const Err(StorageFailure()));
    return inner.save(scanId: scanId, pose: pose, bytes: bytes);
  }

  @override
  Future<Result<Uint8List>> load(StoredPhoto photo) => inner.load(photo);

  @override
  Future<Result<void>> deleteScan(String scanId) => inner.deleteScan(scanId);
}

class _ScriptedMonitor implements CaptureQualityMonitor {
  _ScriptedMonitor(this.script);
  final List<CaptureQuality> script;

  @override
  Stream<CaptureQuality> watch(FacePose pose) => Stream.fromIterable(script);
}
