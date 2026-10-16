import 'dart:typed_data';

/// Makes a stored face photo small enough to send to the AI coach (the photo on
/// the phone is never changed).
abstract interface class PhotoShrinker {
  /// A smaller JPEG of [photo], or null when it is not a readable picture.
  Future<Uint8List?> shrink(Uint8List photo);
}
