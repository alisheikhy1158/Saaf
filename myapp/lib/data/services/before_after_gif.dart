import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// The two photos (and their date labels) for the before-and-after animation.
class BeforeAfterFrames {
  const BeforeAfterFrames({
    required this.before,
    required this.after,
    required this.beforeLabel,
    required this.afterLabel,
  });

  final Uint8List before;
  final Uint8List after;
  final String beforeLabel;
  final String afterLabel;

  /// The animation's width in pixels (small enough to share quickly).
  static const int width = 480;

  /// How long each photo shows, in milliseconds.
  static const int frameMs = 1200;
}

/// A looping GIF that switches between the two photos, each labelled with its
/// date, both cut to the same size. Null when a photo cannot be read. Made on
/// the phone (run it with `compute`, it takes a moment); nothing is sent.
Uint8List? makeBeforeAfterGif(BeforeAfterFrames frames) {
  final before = img.decodeImage(frames.before);
  final after = img.decodeImage(frames.after);
  if (before == null || after == null) return null;

  // The size of the first photo, at most [BeforeAfterFrames.width] wide. Both
  // photos come from the same camera, so the second only changes scale.
  final width = BeforeAfterFrames.width.clamp(1, before.width);
  final height = (width * before.height / before.width).round();
  img.Image frame(img.Image photo, String label) {
    final sized = img.copyResize(photo, width: width, height: height);
    img.fillRect(
      sized,
      x1: 0,
      y1: height - 40,
      x2: width,
      y2: height,
      color: img.ColorRgba8(0, 0, 0, 140),
    );
    img.drawString(
      sized,
      label,
      font: img.arial24,
      x: 12,
      y: height - 34,
      color: img.ColorRgb8(255, 255, 255),
    );
    return sized..frameDuration = BeforeAfterFrames.frameMs;
  }

  final animation = frame(before, frames.beforeLabel)..loopCount = 0;
  animation.addFrame(frame(after, frames.afterLabel));
  return img.encodeGif(animation);
}
