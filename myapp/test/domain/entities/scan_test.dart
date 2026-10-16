// Covers: the 3-pose face scan (front, left side, right side) built on Figma 06,
// CaptureQuality (Good light / Centred / Hold still chips), PRV-1/2
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/camera_facing.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/scan_photo.dart';
import 'package:saaf/domain/entities/scan_session.dart';

ScanPhoto photo(FacePose pose, [int byte = 1]) => ScanPhoto(
  pose: pose,
  bytes: Uint8List.fromList([byte, byte]),
  capturedAt: DateTime.utc(2026, 10, 17, 9),
);

void main() {
  group('FacePose', () {
    test('three poses in capture order: front, left, right', () {
      expect(FacePose.values.map((p) => p.name), ['front', 'left', 'right']);
      expect(FacePose.values.map((p) => p.number), [1, 2, 3]);
      expect(FacePose.count, 3);
    });

    test('next walks front → left → right → null', () {
      expect(FacePose.front.next, FacePose.left);
      expect(FacePose.left.next, FacePose.right);
      expect(FacePose.right.next, isNull);
    });

    test('previous is the reverse', () {
      expect(FacePose.front.previous, isNull);
      expect(FacePose.left.previous, FacePose.front);
      expect(FacePose.right.previous, FacePose.left);
    });

    test('profile poses are the side ones', () {
      expect(FacePose.front.isProfile, isFalse);
      expect(FacePose.left.isProfile, isTrue);
      expect(FacePose.right.isProfile, isTrue);
    });
  });

  group('CameraFacing', () {
    test('flipped toggles', () {
      expect(CameraFacing.front.flipped, CameraFacing.back);
      expect(CameraFacing.back.flipped, CameraFacing.front);
    });
  });

  group('CaptureQuality', () {
    test('is ready only when light, centring and steadiness are all fine', () {
      const ok = CaptureQuality(lightOk: true, centred: true, steady: true);
      expect(ok.isReady, isTrue);
      expect(ok.copyWith(lightOk: false).isReady, isFalse);
      expect(ok.copyWith(centred: false).isReady, isFalse);
      expect(ok.copyWith(steady: false).isReady, isFalse);
    });

    test('starts as "not ready" with no advice', () {
      expect(CaptureQuality.initial.isReady, isFalse);
      expect(CaptureQuality.initial.advice, LightAdvice.none);
    });

    test('light advice only applies while the light is not ok', () {
      const dark = CaptureQuality(
        lightOk: false,
        centred: true,
        steady: true,
        advice: LightAdvice.tooDark,
      );
      expect(dark.advice, LightAdvice.tooDark);
    });
  });

  group('ScanSession', () {
    final started = DateTime.utc(2026, 10, 17, 9);

    test('starts empty and needs the front photo first', () {
      final session = ScanSession.start(id: 'scan-1', startedAt: started);
      expect(session.photos, isEmpty);
      expect(session.isComplete, isFalse);
      expect(session.nextMissing, FacePose.front);
      expect(session.capturedCount, 0);
    });

    test('adding photos moves on to the next missing pose', () {
      var session = ScanSession.start(id: 's', startedAt: started);
      session = session.withPhoto(photo(FacePose.front));
      expect(session.nextMissing, FacePose.left);
      session = session.withPhoto(photo(FacePose.left));
      expect(session.nextMissing, FacePose.right);
      session = session.withPhoto(photo(FacePose.right));
      expect(session.nextMissing, isNull);
      expect(session.isComplete, isTrue);
      expect(session.capturedCount, 3);
    });

    test('poses can be captured out of order', () {
      var session = ScanSession.start(
        id: 's',
        startedAt: started,
      ).withPhoto(photo(FacePose.right));
      expect(session.nextMissing, FacePose.front);
      expect(session.isComplete, isFalse);
    });

    test('a retake replaces the earlier photo of that pose', () {
      var session = ScanSession.start(
        id: 's',
        startedAt: started,
      ).withPhoto(photo(FacePose.front, 1)).withPhoto(photo(FacePose.front, 2));
      expect(session.capturedCount, 1);
      expect(session.photos[FacePose.front]!.bytes.first, 2);
    });

    test('withoutPose removes one photo', () {
      var session = ScanSession.start(id: 's', startedAt: started)
          .withPhoto(photo(FacePose.front))
          .withPhoto(photo(FacePose.left))
          .withoutPose(FacePose.front);
      expect(session.photos.keys, [FacePose.left]);
      expect(session.nextMissing, FacePose.front);
    });

    test('the photo map cannot be changed from outside', () {
      final session = ScanSession.start(
        id: 's',
        startedAt: started,
      ).withPhoto(photo(FacePose.front));
      expect(
        () => session.photos[FacePose.left] = photo(FacePose.left),
        throwsUnsupportedError,
      );
    });

    test('photos in pose order, not capture order', () {
      final session = ScanSession.start(id: 's', startedAt: started)
          .withPhoto(photo(FacePose.right))
          .withPhoto(photo(FacePose.front))
          .withPhoto(photo(FacePose.left));
      expect(session.orderedPhotos.map((p) => p.pose), FacePose.values);
    });
  });

  group('ScanPhoto', () {
    test('keeps its pose, bytes and time', () {
      final p = photo(FacePose.left, 7);
      expect(p.pose, FacePose.left);
      expect(p.bytes, [7, 7]);
      expect(p.capturedAt, DateTime.utc(2026, 10, 17, 9));
    });
  });
}
