// Covers: the scan screen's real checks (phone-test feedback: it took any photo) —
// is there one face, is the light fine, is the face centred, is the head turned
// for THIS pose, is the phone steady, and does the finished photo pass
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/frame_measurement.dart';
import 'package:saaf/domain/usecases/analyse_frame.dart';

FaceObservation face({
  double x = 0.5,
  double y = 0.5,
  double width = 0.5,
  double yaw = 0,
  double roll = 0,
}) => FaceObservation(
  centerX: x,
  centerY: y,
  widthFraction: width,
  yawDegrees: yaw,
  rollDegrees: roll,
);

FrameMeasurement frame({
  double brightness = 120,
  List<FaceObservation>? faces,
}) => FrameMeasurement(brightness: brightness, faces: faces ?? [face()]);

/// Three identical frames so the "steady" streak is reached.
CaptureQuality settle(
  FrameQualityAnalyzer a,
  FacePose pose,
  FrameMeasurement m,
) {
  late CaptureQuality q;
  for (var i = 0; i < FrameQualityAnalyzer.steadyFramesNeeded; i++) {
    q = a.analyse(pose, m);
  }
  return q;
}

void main() {
  group('front photo', () {
    test('a centred, straight, well-lit, still face is ready', () {
      final q = settle(FrameQualityAnalyzer(), FacePose.front, frame());
      expect(q.isReady, isTrue);
      expect(q.lightOk && q.centred && q.poseOk && q.steady, isTrue);
      expect(q.advice, LightAdvice.none);
      expect(q.faceAdvice, FaceAdvice.none);
    });

    test('no face: not ready, and says so', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: const []),
      );
      expect(q.isReady, isFalse);
      expect(q.centred, isFalse);
      expect(q.faceAdvice, FaceAdvice.noFace);
    });

    test('two faces: not ready', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(x: 0.3), face(x: 0.7)]),
      );
      expect(q.isReady, isFalse);
      expect(q.faceAdvice, FaceAdvice.severalFaces);
    });

    test('too far away or too close', () {
      final far = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(width: 0.15)]),
      );
      expect(far.faceAdvice, FaceAdvice.moveCloser);
      final near = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(width: 0.92)]),
      );
      expect(near.faceAdvice, FaceAdvice.moveBack);
      expect(far.centred || near.centred, isFalse);
    });

    test('face off to the side of the frame', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(x: 0.85)]),
      );
      expect(q.centred, isFalse);
      expect(q.faceAdvice, FaceAdvice.centreFace);
    });

    test('head turned: asks to look straight', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(yaw: 25)]),
      );
      expect(q.poseOk, isFalse);
      expect(q.faceAdvice, FaceAdvice.lookStraight);
    });

    test('a small turn is still straight enough', () {
      final q = settle(
        FrameQualityAnalyzer(),
        FacePose.front,
        frame(faces: [face(yaw: 8)]),
      );
      expect(q.poseOk, isTrue);
    });

    test('head tilted sideways asks to look straight', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(faces: [face(roll: 30)]),
      );
      expect(q.poseOk, isFalse);
    });
  });

  group('light', () {
    test('too dark', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(brightness: 30),
      );
      expect(q.lightOk, isFalse);
      expect(q.advice, LightAdvice.tooDark);
      expect(q.isReady, isFalse);
    });

    test('too bright', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(brightness: 240),
      );
      expect(q.lightOk, isFalse);
      expect(q.advice, LightAdvice.tooBright);
    });

    test('deeper skin tones in good light are not called dark', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.front,
        frame(brightness: 75),
      );
      expect(q.lightOk, isTrue);
    });
  });

  group('side profiles', () {
    test('left cheek: head turned about 30 degrees to the left is ready', () {
      final q = settle(
        FrameQualityAnalyzer(),
        FacePose.left,
        frame(faces: [face(yaw: 30, width: 0.4)]),
      );
      expect(q.poseOk, isTrue);
      expect(q.isReady, isTrue);
    });

    test('right cheek: turned about 30 degrees to the right is ready', () {
      final q = settle(
        FrameQualityAnalyzer(),
        FacePose.right,
        frame(faces: [face(yaw: -30, width: 0.4)]),
      );
      expect(q.poseOk, isTrue);
      expect(q.isReady, isTrue);
    });

    test('a front-facing head is NOT a side profile', () {
      final left = FrameQualityAnalyzer().analyse(
        FacePose.left,
        frame(faces: [face(yaw: 2)]),
      );
      expect(left.poseOk, isFalse);
      expect(left.faceAdvice, FaceAdvice.turnLeft);
      final right = FrameQualityAnalyzer().analyse(
        FacePose.right,
        frame(faces: [face(yaw: -3)]),
      );
      expect(right.poseOk, isFalse);
      expect(right.faceAdvice, FaceAdvice.turnRight);
    });

    test('turned the wrong way for this cheek', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.left,
        frame(faces: [face(yaw: -30)]),
      );
      expect(q.poseOk, isFalse);
      expect(q.faceAdvice, FaceAdvice.turnLeft);
    });

    test('turned too far', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.left,
        frame(faces: [face(yaw: 70)]),
      );
      expect(q.poseOk, isFalse);
      expect(q.faceAdvice, FaceAdvice.turnLess);
    });

    test('a narrower side face is still accepted as big enough', () {
      final q = FrameQualityAnalyzer().analyse(
        FacePose.left,
        frame(faces: [face(yaw: 30, width: 0.28)]),
      );
      expect(q.centred, isTrue);
    });
  });

  group('holding still', () {
    test('is not steady on the first frame', () {
      final q = FrameQualityAnalyzer().analyse(FacePose.front, frame());
      expect(q.steady, isFalse);
    });

    test('becomes steady after a few similar frames', () {
      final q = settle(FrameQualityAnalyzer(), FacePose.front, frame());
      expect(q.steady, isTrue);
    });

    test('moving the phone breaks the streak', () {
      final a = FrameQualityAnalyzer();
      settle(a, FacePose.front, frame());
      final q = a.analyse(FacePose.front, frame(faces: [face(x: 0.6)]));
      expect(q.steady, isFalse);
    });

    test('losing the face resets it', () {
      final a = FrameQualityAnalyzer();
      settle(a, FacePose.front, frame());
      a.analyse(FacePose.front, frame(faces: const []));
      expect(a.analyse(FacePose.front, frame()).steady, isFalse);
    });
  });

  group('the finished photo', () {
    PhotoCheck check(FacePose pose, FrameMeasurement m) => checkPhoto(pose, m);

    test('good front photo', () {
      expect(check(FacePose.front, frame()), PhotoCheck.ok);
    });

    test('no face', () {
      expect(check(FacePose.front, frame(faces: const [])), PhotoCheck.noFace);
    });

    test('more than one face', () {
      expect(
        check(FacePose.front, frame(faces: [face(x: 0.3), face(x: 0.7)])),
        PhotoCheck.severalFaces,
      );
    });

    test('a front photo with the head turned', () {
      expect(
        check(FacePose.front, frame(faces: [face(yaw: 30)])),
        PhotoCheck.wrongPose,
      );
    });

    test('a left photo taken facing the camera', () {
      expect(
        check(FacePose.left, frame(faces: [face(yaw: 3)])),
        PhotoCheck.wrongPose,
      );
    });

    test('a proper left profile', () {
      expect(
        check(FacePose.left, frame(faces: [face(yaw: 32, width: 0.4)])),
        PhotoCheck.ok,
      );
    });

    test('a face that is tiny in the picture', () {
      expect(
        check(FacePose.front, frame(faces: [face(width: 0.08)])),
        PhotoCheck.tooSmall,
      );
    });

    test('too dark and too bright', () {
      expect(check(FacePose.front, frame(brightness: 20)), PhotoCheck.tooDark);
      expect(
        check(FacePose.front, frame(brightness: 250)),
        PhotoCheck.tooBright,
      );
    });

    test('a photo does not need to be perfectly centred', () {
      expect(
        check(FacePose.front, frame(faces: [face(x: 0.7, y: 0.4)])),
        PhotoCheck.ok,
      );
    });
  });
}
