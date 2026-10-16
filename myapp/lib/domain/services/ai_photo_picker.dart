import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';

/// Gets a photo for the AI coach from the camera or the gallery (the system
/// screens: no extra permission needed). Photos are shrunk as they are chosen.
abstract interface class AiPhotoPicker {
  /// The photo, or null when the user cancelled.
  Future<Result<Uint8List?>> pick(AiPhotoSource source);
}
