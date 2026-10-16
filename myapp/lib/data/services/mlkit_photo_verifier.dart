import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:saaf/data/services/face_frame_conversion.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/frame_measurement.dart';
import 'package:saaf/domain/services/photo_verifier.dart';
import 'package:saaf/domain/usecases/analyse_frame.dart';

/// Checks a finished photo with ML Kit's on-device face detector. The picture
/// is shrunk, looked at in memory and dropped; nothing is uploaded or saved.
///
/// Some phones store a photo sideways and record the turn in a tag, and it is
/// not certain every decoder applies it, so the face is looked for upright
/// first and then at the other three turns, keeping the clearest result.
class MlKitPhotoVerifier implements PhotoVerifier {
  MlKitPhotoVerifier();

  /// Photos are shrunk to this width before looking (plenty for a face).
  static const _width = 640;

  @override
  Future<PhotoCheck> check(FacePose pose, Uint8List bytes) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.1,
      ),
    );
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: _width);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final pixels = await image.toByteData();
      if (pixels == null) return PhotoCheck.unavailable;
      final data = pixels.buffer.asUint8List();
      final size = ui.Size(image.width.toDouble(), image.height.toDouble());

      List<Face> best = const [];
      ui.Size bestSize = size;
      var bestArea = -1.0;
      for (final turn in const [
        InputImageRotation.rotation0deg,
        InputImageRotation.rotation90deg,
        InputImageRotation.rotation270deg,
        InputImageRotation.rotation180deg,
      ]) {
        final faces = await detector.processImage(
          InputImage.fromBitmap(
            bitmap: data,
            width: image.width,
            height: image.height,
            rotation: turn.rawValue,
          ),
        );
        if (faces.isEmpty) continue;
        final area = faces
            .map((f) => f.boundingBox.width * f.boundingBox.height)
            .reduce((a, b) => a > b ? a : b);
        if (area > bestArea) {
          bestArea = area;
          best = faces;
          bestSize = uprightSize(size, turn);
        }
        // An upright, level face needs no more looking.
        final level =
            faces.length == 1 &&
            (faces.single.headEulerAngleZ ?? 0).abs() <= 20;
        if (turn == InputImageRotation.rotation0deg && level) break;
      }

      return checkPhoto(
        pose,
        FrameMeasurement(
          // Brightness is judged live; a finished photo is not measured.
          brightness: 128,
          faces: [
            for (final face in best)
              observationFrom(
                box: face.boundingBox,
                yaw: face.headEulerAngleY,
                roll: face.headEulerAngleZ,
                upright: bestSize,
                mirrored: false,
              ),
          ],
        ),
      );
    } on Object {
      return PhotoCheck.unavailable;
    } finally {
      try {
        await detector.close();
      } on Object {
        // Already closed.
      }
    }
  }
}
