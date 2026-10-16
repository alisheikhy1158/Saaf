// Covers: 06 Selfie capture — three-pose flow (front, left, right), permission
// flow (store-compliance §1), auto-capture countdown, retake, save (PRV-1)
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/web/fake_camera_service.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/data/services/web/fake_photo_picker.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/photo_picker.dart';
import 'package:saaf/presentation/features/scan/controllers/scan_controller.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 10, 15, 9, 41);
}

/// A monitor the test drives by hand.
class _Monitor implements CaptureQualityMonitor {
  final List<StreamController<CaptureQuality>> controllers = [];
  final List<FacePose> watched = [];

  @override
  Stream<CaptureQuality> watch(FacePose pose) {
    watched.add(pose);
    final controller = StreamController<CaptureQuality>();
    controllers.add(controller);
    return controller.stream;
  }

  void emit(CaptureQuality quality) => controllers.last.add(quality);
}

class _FailingCamera extends FakeCameraService {
  _FailingCamera(this.failure);
  final Failure failure;

  @override
  Future<Result<void>> open(CameraFacing facing) async => Err(failure);
}

class _OneCamera extends FakeCameraService {
  @override
  bool get canFlip => false;
}

class _FailingStore extends InMemoryPhotoStore {
  @override
  Future<Result<StoredPhoto>> save({
    required String scanId,
    required FacePose pose,
    required Uint8List bytes,
  }) async => const Err(StorageFailure());
}

class _CancelPicker implements PhotoPicker {
  @override
  Future<Result<Uint8List?>> pickFromGallery() async => const Ok(null);
}

const _ready = CaptureQuality(lightOk: true, centred: true, steady: true);
const _dark = CaptureQuality(
  lightOk: false,
  centred: true,
  steady: true,
  advice: LightAdvice.tooDark,
);

void main() {
  late _Monitor monitor;
  late FakeCameraService camera;
  late InMemoryPhotoStore store;

  setUp(() {
    monitor = _Monitor();
    camera = FakeCameraService();
    store = InMemoryPhotoStore();
  });

  ProviderContainer make(
    WidgetTester tester, {
    CameraPermission permission = CameraPermission.granted,
    bool grantsOnRequest = true,
    FakeCameraService? cameraOverride,
    PhotoPicker? picker,
    InMemoryPhotoStore? storeOverride,
  }) {
    final container = ProviderContainer(
      overrides: [
        permissionServiceProvider.overrideWithValue(
          FakePermissionService(permission, grantsOnRequest: grantsOnRequest),
        ),
        cameraDeviceProvider.overrideWithValue((
          service: cameraOverride ?? camera,
          preview: cameraOverride ?? camera,
        )),
        captureQualityMonitorProvider.overrideWithValue(monitor),
        photoPickerProvider.overrideWithValue(picker ?? FakePhotoPicker()),
        photoStoreProvider.overrideWithValue(storeOverride ?? store),
        clockProvider.overrideWithValue(_Clock()),
      ],
    );
    addTearDown(container.dispose);
    // Keep it alive like the screen does.
    container.listen(scanControllerProvider, (_, _) {});
    return container;
  }

  ScanState read(ProviderContainer c) => c.read(scanControllerProvider);
  ScanController notifier(ProviderContainer c) =>
      c.read(scanControllerProvider.notifier);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  group('permission flow', () {
    testWidgets('granted: opens the camera on the front pose', (tester) async {
      final c = make(tester);
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).pose, FacePose.front);
      expect(read(c).facing, CameraFacing.front);
      expect(monitor.watched, [FacePose.front]);
    });

    testWidgets('not asked yet: shows our own explanation first', (
      tester,
    ) async {
      final c = make(tester, permission: CameraPermission.denied);
      await settle(tester);
      expect(read(c).phase, ScanPhase.needsRationale);
      expect(monitor.watched, isEmpty);
    });

    testWidgets('continuing from the explanation asks and opens the camera', (
      tester,
    ) async {
      final c = make(tester, permission: CameraPermission.denied);
      await settle(tester);
      await notifier(c).continueFromRationale();
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
    });

    testWidgets('refusing the system dialog leads to the denied state', (
      tester,
    ) async {
      final c = make(
        tester,
        permission: CameraPermission.denied,
        grantsOnRequest: false,
      );
      await settle(tester);
      await notifier(c).continueFromRationale();
      await settle(tester);
      // The fake refuses for good, so settings are the only way.
      expect(read(c).phase, ScanPhase.needsSettings);
    });

    testWidgets('permanently denied: offers the phone settings', (
      tester,
    ) async {
      final c = make(tester, permission: CameraPermission.permanentlyDenied);
      await settle(tester);
      expect(read(c).phase, ScanPhase.needsSettings);
    });

    testWidgets('the camera refusing access is treated as denied', (
      tester,
    ) async {
      final c = make(
        tester,
        cameraOverride: _FailingCamera(const PermissionDenied()),
      );
      await settle(tester);
      expect(read(c).phase, ScanPhase.needsSettings);
    });

    testWidgets('any other camera error shows a failure with retry', (
      tester,
    ) async {
      final c = make(
        tester,
        cameraOverride: _FailingCamera(const UnknownFailure('x')),
      );
      await settle(tester);
      expect(read(c).phase, ScanPhase.failed);
      await notifier(c).retry();
      await settle(tester);
      expect(read(c).phase, ScanPhase.failed);
    });
  });

  group('quality and auto-capture', () {
    testWidgets('shows the monitor\'s advice', (tester) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_dark);
      await tester.pump();
      expect(read(c).quality.advice, LightAdvice.tooDark);
      expect(read(c).countdown, isNull);
    });

    testWidgets('when ready, counts down 2, 1 and then takes the photo', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_ready);
      await tester.pump();
      expect(read(c).countdown, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(read(c).countdown, 1);
      expect(read(c).phase, ScanPhase.live);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).session.photos.keys, [FacePose.front]);
    });

    testWidgets('losing the light cancels the countdown', (tester) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_ready);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      monitor.emit(_dark);
      await tester.pump();
      expect(read(c).countdown, isNull);
      await tester.pump(const Duration(seconds: 5));
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).session.capturedCount, 0);
    });

    testWidgets('the shutter takes a photo at once, even when not ready', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      await notifier(c).capture();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).reviewPhoto?.pose, FacePose.front);
    });

    testWidgets('pressing the shutter twice does not take two photos', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      final first = notifier(c).capture();
      final second = notifier(c).capture();
      await Future.wait([first, second]);
      await settle(tester);
      expect(read(c).session.capturedCount, 1);
    });
  });

  group('three poses', () {
    Future<void> takeAndAccept(WidgetTester tester, ProviderContainer c) async {
      await notifier(c).capture();
      await settle(tester);
      await notifier(c).accept();
      await settle(tester);
    }

    testWidgets('front, then left, then right, then saved', (tester) async {
      final c = make(tester);
      await settle(tester);

      await takeAndAccept(tester, c);
      expect(read(c).pose, FacePose.left);
      expect(read(c).phase, ScanPhase.live);
      expect(monitor.watched, [FacePose.front, FacePose.left]);

      await takeAndAccept(tester, c);
      expect(read(c).pose, FacePose.right);

      await notifier(c).capture();
      await settle(tester);
      expect(read(c).session.isComplete, isTrue);
      expect(read(c).phase, ScanPhase.reviewing);

      await notifier(c).accept();
      await settle(tester);
      expect(read(c).phase, ScanPhase.done);

      final scan = c.read(completedScanProvider);
      expect(scan, isNotNull);
      // It is also kept in the history the progress comparison uses.
      expect(c.read(scanHistoryProvider), [scan]);
      expect(scan!.photos.map((p) => p.pose), FacePose.values);
      for (final photo in scan.photos) {
        expect((await store.load(photo)).isOk, isTrue);
      }
    });

    testWidgets('retake throws the photo away and shows the camera again', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      await notifier(c).capture();
      await settle(tester);
      await notifier(c).retake();
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).pose, FacePose.front);
      expect(read(c).session.capturedCount, 0);
      expect(read(c).reviewPhoto, isNull);
    });

    testWidgets('a finished pose can be opened again from the stepper', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      await takeAndAccept(tester, c);
      notifier(c).selectPose(FacePose.front);
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).pose, FacePose.front);
      // Keeping it moves on to the first pose still missing.
      await notifier(c).accept();
      await settle(tester);
      expect(read(c).pose, FacePose.left);
      expect(read(c).phase, ScanPhase.live);
    });

    testWidgets(
      'a pose that is not taken yet and not next cannot be selected',
      (tester) async {
        final c = make(tester);
        await settle(tester);
        notifier(c).selectPose(FacePose.right);
        await settle(tester);
        expect(read(c).pose, FacePose.front);
      },
    );

    testWidgets('a gallery photo can stand in for a pose', (tester) async {
      final c = make(tester);
      await settle(tester);
      await notifier(c).pickFromGallery();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).reviewPhoto?.pose, FacePose.front);
    });

    testWidgets('cancelling the gallery changes nothing', (tester) async {
      final c = make(tester, picker: _CancelPicker());
      await settle(tester);
      await notifier(c).pickFromGallery();
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).failure, isNull);
    });

    testWidgets('a save error keeps the photos so the user can try again', (
      tester,
    ) async {
      final c = make(tester, storeOverride: _FailingStore());
      await settle(tester);
      await takeAndAccept(tester, c);
      await takeAndAccept(tester, c);
      await notifier(c).capture();
      await settle(tester);
      await notifier(c).accept();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).failure, const StorageFailure());
      expect(read(c).session.isComplete, isTrue);
      expect(c.read(completedScanProvider), isNull);
    });
  });

  group('controls', () {
    testWidgets('flip switches to the other camera', (tester) async {
      final c = make(tester);
      await settle(tester);
      await notifier(c).flip();
      await settle(tester);
      expect(read(c).facing, CameraFacing.back);
      expect(camera.facing, CameraFacing.back);
      expect(read(c).phase, ScanPhase.live);
    });

    testWidgets('canFlip comes from the camera', (tester) async {
      final c = make(tester, cameraOverride: _OneCamera());
      await settle(tester);
      expect(read(c).canFlip, isFalse);
    });

    testWidgets('the light button toggles the fill light', (tester) async {
      final c = make(tester);
      await settle(tester);
      expect(read(c).fillLight, isFalse);
      notifier(c).toggleFillLight();
      expect(read(c).fillLight, isTrue);
    });

    testWidgets('leaving the screen closes the camera', (tester) async {
      final c = make(tester);
      await settle(tester);
      c.dispose();
      await tester.pump();
      expect(camera.facing, isNull);
    });
  });
}
