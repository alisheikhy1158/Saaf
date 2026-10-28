// Covers: 06 Selfie capture — the real checks from the first phone test: the
// shutter stays locked until face, light, angle and steadiness are right, and
// every photo (camera or gallery) is checked again once it is taken
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/web/fake_camera_service.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/data/services/web/fake_photo_picker.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/photo_check.dart';
import 'package:saaf/domain/services/capture_quality_monitor.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/photo_verifier.dart';
import 'package:saaf/presentation/features/scan/controllers/scan_controller.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 10, 15, 9, 41);
}

class _Monitor implements CaptureQualityMonitor {
  final List<StreamController<CaptureQuality>> controllers = [];

  @override
  Stream<CaptureQuality> watch(FacePose pose) {
    final controller = StreamController<CaptureQuality>();
    controllers.add(controller);
    return controller.stream;
  }

  void emit(CaptureQuality quality) => controllers.last.add(quality);
}

class _Verifier implements PhotoVerifier {
  _Verifier(this.verdict);
  PhotoCheck verdict;
  final List<FacePose> asked = [];

  @override
  Future<PhotoCheck> check(FacePose pose, Uint8List bytes) async {
    asked.add(pose);
    return verdict;
  }
}

const _lockedAssessed = CaptureQuality(
  lightOk: true,
  centred: false,
  steady: false,
  poseOk: false,
  faceAdvice: FaceAdvice.noFace,
  assessed: true,
);
const _readyAssessed = CaptureQuality(
  lightOk: true,
  centred: true,
  steady: true,
  assessed: true,
);
const _failedAssessment = CaptureQuality(
  lightOk: false,
  centred: false,
  steady: false,
  poseOk: false,
);

void main() {
  late _Monitor monitor;
  late _Verifier verifier;

  setUp(() {
    monitor = _Monitor();
    verifier = _Verifier(PhotoCheck.ok);
  });

  ProviderContainer make(WidgetTester tester) {
    final camera = FakeCameraService();
    final container = ProviderContainer(
      overrides: [
        permissionServiceProvider.overrideWithValue(
          FakePermissionService(CameraPermission.granted),
        ),
        cameraDeviceProvider.overrideWithValue((
          service: camera,
          preview: camera,
        )),
        captureQualityMonitorProvider.overrideWithValue(monitor),
        photoVerifierProvider.overrideWithValue(verifier),
        photoPickerProvider.overrideWithValue(FakePhotoPicker()),
        photoStoreProvider.overrideWithValue(InMemoryPhotoStore()),
        clockProvider.overrideWithValue(_Clock()),
      ],
    );
    addTearDown(container.dispose);
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

  group('the shutter is locked until the checks pass', () {
    testWidgets('a checked frame that is not ready locks the shutter', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_lockedAssessed);
      await tester.pump();
      expect(read(c).shutterLocked, isTrue);
      await notifier(c).capture();
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).session.capturedCount, 0);
    });

    testWidgets('once everything is right the shutter works', (tester) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_lockedAssessed);
      await tester.pump();
      monitor.emit(_readyAssessed);
      await tester.pump();
      expect(read(c).shutterLocked, isFalse);
      await notifier(c).capture();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
    });

    testWidgets('losing the face locks it again', (tester) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_readyAssessed);
      await tester.pump();
      monitor.emit(_lockedAssessed);
      await tester.pump();
      expect(read(c).shutterLocked, isTrue);
    });

    testWidgets('if the checks stop working the shutter is free again', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_lockedAssessed);
      await tester.pump();
      monitor.emit(_failedAssessment);
      await tester.pump();
      expect(read(c).shutterLocked, isFalse);
      await notifier(c).capture();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
    });

    testWidgets('a monitor that does not check frames never locks it', (
      tester,
    ) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(
        const CaptureQuality(lightOk: false, centred: false, steady: false),
      );
      await tester.pump();
      expect(read(c).shutterLocked, isFalse);
    });

    testWidgets('the auto-capture still fires when ready', (tester) async {
      final c = make(tester);
      await settle(tester);
      monitor.emit(_readyAssessed);
      await tester.pump();
      expect(read(c).countdown, ScanController.countdownSeconds);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(read(c).session.capturedCount, 1);
    });
  });

  group('every photo is checked once it is taken', () {
    Future<ProviderContainer> takeFront(WidgetTester tester) async {
      final c = make(tester);
      await settle(tester);
      await notifier(c).capture();
      await settle(tester);
      return c;
    }

    testWidgets('a good photo is marked ok', (tester) async {
      final c = await takeFront(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).photoCheck, PhotoCheck.ok);
      expect(verifier.asked, [FacePose.front]);
    });

    testWidgets('a photo without a face is flagged', (tester) async {
      verifier.verdict = PhotoCheck.noFace;
      final c = await takeFront(tester);
      expect(read(c).photoCheck, PhotoCheck.noFace);
    });

    testWidgets('it can still be kept ("use it anyway")', (tester) async {
      verifier.verdict = PhotoCheck.wrongPose;
      final c = await takeFront(tester);
      await notifier(c).accept();
      await settle(tester);
      expect(read(c).session.capturedCount, 1);
      expect(read(c).pose, FacePose.left);
      expect(read(c).photoCheck, isNull);
    });

    testWidgets('retaking clears the verdict', (tester) async {
      verifier.verdict = PhotoCheck.tooDark;
      final c = await takeFront(tester);
      await notifier(c).retake();
      await settle(tester);
      expect(read(c).phase, ScanPhase.live);
      expect(read(c).photoCheck, isNull);
    });

    testWidgets('a gallery photo is checked for the pose being asked', (
      tester,
    ) async {
      verifier.verdict = PhotoCheck.severalFaces;
      final c = make(tester);
      await settle(tester);
      await notifier(c).pickFromGallery();
      await settle(tester);
      expect(read(c).phase, ScanPhase.reviewing);
      expect(read(c).photoCheck, PhotoCheck.severalFaces);
      expect(verifier.asked, [FacePose.front]);
    });

    testWidgets(
      'no detector on this phone: the photo is kept without a verdict',
      (tester) async {
        verifier.verdict = PhotoCheck.unavailable;
        final c = await takeFront(tester);
        expect(read(c).photoCheck, PhotoCheck.unavailable);
        await notifier(c).accept();
        await settle(tester);
        expect(read(c).session.capturedCount, 1);
      },
    );
  });
}
