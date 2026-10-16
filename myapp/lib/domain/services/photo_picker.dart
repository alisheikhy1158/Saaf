import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';

/// Chooses an existing photo with the system picker (no library permission needed).
abstract interface class PhotoPicker {
  /// The chosen image, or null when the user cancelled.
  Future<Result<Uint8List?>> pickFromGallery();
}
