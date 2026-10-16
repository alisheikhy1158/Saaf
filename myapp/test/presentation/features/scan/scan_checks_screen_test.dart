// Covers: Figma 06 Selfie capture — what the user sees now that the phone really
// checks the picture: face and angle hints, a locked shutter, and a warning on a
// photo that is not usable (phone-test feedback)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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
import 'package:saaf/domain/services/photo_verifier.dart';
import 'package:saaf/presentation/features/scan/screens/selfie_capture_screen.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_camera_controls.dart';
import 'dart:typed_data';

import '../../../helpers/pump_app.dart';

class _Monitor implements CaptureQualityMonitor {
  _Monitor(this.quality);
  final CaptureQuality quality;

  @override
  Stream<CaptureQuality> watch(FacePose pose) => Stream.value(quality);
}

class _Verifier implements PhotoVerifier {
  _Verifier(this.verdict);
  final PhotoCheck verdict;

  @override
  Future<PhotoCheck> check(FacePose pose, Uint8List bytes) async => verdict;
}

const _noFace = CaptureQuality(
  lightOk: true,
  centred: false,
  steady: false,
  poseOk: false,
  faceAdvice: FaceAdvice.noFace,
  assessed: true,
);
const _ready = CaptureQuality(
  lightOk: true,
  centred: true,
  steady: true,
  assessed: true,
);

List<Override> _overrides(CaptureQuality quality, PhotoCheck verdict) {
  final camera = FakeCameraService();
  return [
    permissionServiceProvider.overrideWithValue(
      FakePermissionService(CameraPermission.granted),
    ),
    cameraDeviceProvider.overrideWithValue((service: camera, preview: camera)),
    captureQualityMonitorProvider.overrideWithValue(_Monitor(quality)),
    photoVerifierProvider.overrideWithValue(_Verifier(verdict)),
    photoPickerProvider.overrideWithValue(FakePhotoPicker()),
    photoStoreProvider.overrideWithValue(InMemoryPhotoStore()),
  ];
}

Future<void> _open(
  WidgetTester tester,
  CaptureQuality quality, {
  PhotoCheck verdict = PhotoCheck.ok,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const SelfieCaptureScreen(),
    scaffold: false,
    size: size,
    overrides: _overrides(quality, verdict),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump();
}

void main() {
  group('hints while the camera is live', () {
    testWidgets('no face: says so instead of the pose instruction', (
      tester,
    ) async {
      await _open(tester, _noFace);
      expect(find.text('We can’t see your face'), findsOneWidget);
      expect(find.text('Look straight at the camera'), findsNothing);
    });

    for (final (advice, text) in [
      (FaceAdvice.severalFaces, 'Only one face, please'),
      (FaceAdvice.moveCloser, 'Move a little closer'),
      (FaceAdvice.moveBack, 'Move a little back'),
      (FaceAdvice.centreFace, 'Centre your face in the oval'),
      (FaceAdvice.lookStraight, 'Look straight at the camera'),
      (FaceAdvice.turnLeft, 'Turn your head to your left'),
      (FaceAdvice.turnRight, 'Turn your head to your right'),
      (FaceAdvice.turnLess, 'Turn back a little'),
    ]) {
      testWidgets('$advice is spoken', (tester) async {
        await _open(
          tester,
          CaptureQuality(
            lightOk: true,
            centred: false,
            steady: false,
            poseOk: false,
            faceAdvice: advice,
            assessed: true,
          ),
        );
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets('light advice comes before face advice', (tester) async {
      await _open(
        tester,
        const CaptureQuality(
          lightOk: false,
          centred: false,
          steady: false,
          poseOk: false,
          advice: LightAdvice.tooDark,
          faceAdvice: FaceAdvice.noFace,
          assessed: true,
        ),
      );
      expect(find.text('Find brighter light'), findsOneWidget);
    });

    testWidgets('there is a chip for the head angle too', (tester) async {
      await _open(tester, _noFace);
      expect(find.text('Right angle'), findsOneWidget);
      expect(find.bySemanticsLabel('Right angle, not yet'), findsOneWidget);
    });
  });

  group('the shutter', () {
    testWidgets('does nothing while the checks are not met', (tester) async {
      await _open(tester, _noFace);
      expect(
        find.text('The button unlocks when everything is ready'),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(SaafCameraControls.shutterKey));
      expect(find.text('Use this photo'), findsNothing);
      expect(find.text('Retake'), findsNothing);
    });

    testWidgets('works when they are', (tester) async {
      await _open(tester, _ready);
      await _tap(tester, find.byKey(SaafCameraControls.shutterKey));
      expect(find.text('Retake'), findsOneWidget);
    });
  });

  group('a photo that is not usable', () {
    Future<void> takePhoto(WidgetTester tester, PhotoCheck verdict) async {
      await _open(tester, _ready, verdict: verdict);
      await _tap(tester, find.byKey(SaafCameraControls.shutterKey));
      await tester.pump();
    }

    for (final (check, text) in [
      (
        PhotoCheck.noFace,
        'We couldn’t find a face in this photo. Please retake it.',
      ),
      (
        PhotoCheck.severalFaces,
        'There is more than one face in this photo. Please retake it with only you in it.',
      ),
      (
        PhotoCheck.wrongPose,
        'This is not the angle we need for this photo. Please retake it.',
      ),
      (
        PhotoCheck.tooSmall,
        'Your face is too small in this photo. Move closer and retake it.',
      ),
      (
        PhotoCheck.tooDark,
        'This photo is too dark. Find brighter light and retake it.',
      ),
      (
        PhotoCheck.tooBright,
        'This photo is too bright. Move to softer light and retake it.',
      ),
    ]) {
      testWidgets('$check: says what is wrong and asks to retake', (
        tester,
      ) async {
        await takePhoto(tester, check);
        expect(find.text(text), findsOneWidget);
        expect(find.text('Retake'), findsOneWidget);
        expect(find.text('Use it anyway'), findsOneWidget);
        expect(find.text('Use this photo'), findsNothing);
      });
    }

    testWidgets('a good photo shows no warning', (tester) async {
      await takePhoto(tester, PhotoCheck.ok);
      expect(find.text('Use this photo'), findsOneWidget);
      expect(find.text('Use it anyway'), findsNothing);
    });

    testWidgets('no detector on the phone: no warning either', (tester) async {
      await takePhoto(tester, PhotoCheck.unavailable);
      expect(find.text('Use this photo'), findsOneWidget);
    });

    testWidgets('"Use it anyway" still moves on to the next photo', (
      tester,
    ) async {
      await takePhoto(tester, PhotoCheck.noFace);
      await _tap(tester, find.text('Use it anyway'));
      expect(find.text('Left'), findsWidgets);
      expect(find.text('Retake'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('the new hints and warning fit every size', (tester) async {
      for (final size in matrixSizes) {
        await _open(tester, _noFace, size: size);
        expect(tester.takeException(), isNull, reason: '$size live');
        await _open(
          tester,
          _ready,
          verdict: PhotoCheck.severalFaces,
          size: size,
        );
        await _tap(tester, find.byKey(SaafCameraControls.shutterKey));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$size review');
      }
    });
  });
}
