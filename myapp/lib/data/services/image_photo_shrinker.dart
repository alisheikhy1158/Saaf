import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:saaf/domain/services/photo_shrinker.dart';

/// Shrinks a photo with the pure-Dart `image` package, off the main thread:
/// longest side 1024 px, JPEG quality 80 (a face photo then weighs about 100–
/// 300 KB). Works the same on phones and in Chrome.
class ImagePhotoShrinker implements PhotoShrinker {
  const ImagePhotoShrinker();

  static const int longSide = 1024;
  static const int quality = 80;

  @override
  Future<Uint8List?> shrink(Uint8List photo) async {
    if (photo.isEmpty) return null;
    try {
      return await compute(_shrink, photo);
    } on Object {
      return null;
    }
  }

  static Uint8List? _shrink(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final upright = img.bakeOrientation(decoded);
    final longest = math.max(upright.width, upright.height);
    final resized = longest <= longSide
        ? upright
        : img.copyResize(
            upright,
            width: upright.width >= upright.height ? longSide : null,
            height: upright.height > upright.width ? longSide : null,
            interpolation: img.Interpolation.average,
          );
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
}
