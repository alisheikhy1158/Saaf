// Covers: turning a camera frame and a detected face into the numbers the scan
// rules use (rotation, size of the upright picture, face position, brightness)
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:saaf/data/services/face_frame_conversion.dart';

void main() {
  group('imageRotation', () {
    InputImageRotation? rotate({
      required int sensor,
      required bool front,
      DeviceOrientation device = DeviceOrientation.portraitUp,
      TargetPlatform platform = TargetPlatform.android,
    }) => imageRotation(
      sensorOrientation: sensor,
      deviceOrientation: device,
      frontCamera: front,
      platform: platform,
    );

    test('Android front camera held upright', () {
      expect(
        rotate(sensor: 270, front: true),
        InputImageRotation.rotation270deg,
      );
    });

    test('Android back camera held upright', () {
      expect(
        rotate(sensor: 90, front: false),
        InputImageRotation.rotation90deg,
      );
    });

    test('Android turned sideways', () {
      expect(
        rotate(
          sensor: 270,
          front: true,
          device: DeviceOrientation.landscapeLeft,
        ),
        InputImageRotation.rotation0deg,
      );
      expect(
        rotate(
          sensor: 90,
          front: false,
          device: DeviceOrientation.landscapeLeft,
        ),
        InputImageRotation.rotation0deg,
      );
    });

    test('iOS uses the sensor orientation as it is', () {
      expect(
        rotate(sensor: 90, front: true, platform: TargetPlatform.iOS),
        InputImageRotation.rotation90deg,
      );
    });

    test('other platforms have no rotation', () {
      expect(
        rotate(sensor: 90, front: true, platform: TargetPlatform.windows),
        isNull,
      );
    });
  });

  group('uprightSize', () {
    test('a sideways sensor image is turned upright', () {
      expect(
        uprightSize(const Size(640, 480), InputImageRotation.rotation90deg),
        const Size(480, 640),
      );
      expect(
        uprightSize(const Size(640, 480), InputImageRotation.rotation270deg),
        const Size(480, 640),
      );
    });

    test('already upright stays as it is', () {
      expect(
        uprightSize(const Size(480, 640), InputImageRotation.rotation0deg),
        const Size(480, 640),
      );
      expect(
        uprightSize(const Size(480, 640), InputImageRotation.rotation180deg),
        const Size(480, 640),
      );
    });
  });

  group('observationFrom', () {
    test('a box in the middle of the picture', () {
      final face = observationFrom(
        box: const Rect.fromLTRB(120, 220, 360, 460),
        yaw: 20,
        roll: -5,
        upright: const Size(480, 640),
        mirrored: false,
      );
      expect(face.centerX, closeTo(0.5, 1e-9));
      expect(face.centerY, closeTo(340 / 640, 1e-9));
      expect(face.widthFraction, closeTo(0.5, 1e-9));
      expect(face.yawDegrees, 20);
      expect(face.rollDegrees, -5);
    });

    test('a mirrored picture flips left and right', () {
      final face = observationFrom(
        box: const Rect.fromLTRB(0, 0, 100, 100),
        yaw: 20,
        roll: 7,
        upright: const Size(400, 400),
        mirrored: true,
      );
      expect(face.yawDegrees, -20);
      expect(face.rollDegrees, -7);
    });

    test('missing angles count as facing the camera', () {
      final face = observationFrom(
        box: const Rect.fromLTRB(0, 0, 100, 100),
        yaw: null,
        roll: null,
        upright: const Size(400, 400),
        mirrored: false,
      );
      expect(face.yawDegrees, 0);
      expect(face.rollDegrees, 0);
    });
  });

  group('meanBrightness', () {
    test('reads the brightness plane of an NV21 frame', () {
      const w = 8;
      const h = 8;
      final bytes = Uint8List(w * h * 3 ~/ 2)..fillRange(0, w * h, 100);
      expect(
        meanBrightness(
          bytes: bytes,
          width: w,
          height: h,
          bytesPerRow: w,
          bgra: false,
        ),
        closeTo(100, 1e-9),
      );
    });

    test('only the middle of the picture counts', () {
      const w = 8;
      const h = 8;
      final bytes = Uint8List(w * h * 3 ~/ 2);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final inMiddle = x >= 2 && x < 6 && y >= 2 && y < 6;
          bytes[y * w + x] = inMiddle ? 200 : 0;
        }
      }
      expect(
        meanBrightness(
          bytes: bytes,
          width: w,
          height: h,
          bytesPerRow: w,
          bgra: false,
        ),
        closeTo(200, 1e-9),
      );
    });

    test('works out brightness from BGRA pixels', () {
      const w = 4;
      const h = 4;
      final bytes = Uint8List(w * h * 4);
      for (var i = 0; i < w * h; i++) {
        bytes[i * 4 + 1] = 255; // green only
        bytes[i * 4 + 3] = 255;
      }
      expect(
        meanBrightness(
          bytes: bytes,
          width: w,
          height: h,
          bytesPerRow: w * 4,
          bgra: true,
        ),
        closeTo(0.587 * 255, 1.0),
      );
    });

    test('an empty frame is mid-grey, not a crash', () {
      expect(
        meanBrightness(
          bytes: Uint8List(0),
          width: 0,
          height: 0,
          bytesPerRow: 0,
          bgra: false,
        ),
        128,
      );
    });
  });
}
