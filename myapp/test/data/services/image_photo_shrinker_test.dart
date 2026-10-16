// Covers: shrinking a stored face photo before it goes to the AI coach (small,
// fast uploads; the original on the phone is never touched)
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:saaf/data/services/image_photo_shrinker.dart';

Uint8List _jpeg(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(180, 140, 120));
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

Uint8List _png(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(90, 120, 80));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  const shrinker = ImagePhotoShrinker();

  test('a big photo comes back smaller, as a JPEG', () async {
    final result = (await shrinker.shrink(_jpeg(2400, 3200)))!;
    final decoded = img.decodeImage(result)!;
    expect(decoded.width, lessThanOrEqualTo(ImagePhotoShrinker.longSide));
    expect(decoded.height, lessThanOrEqualTo(ImagePhotoShrinker.longSide));
    expect(decoded.height, ImagePhotoShrinker.longSide);
    expect(result[0], 0xFF);
    expect(result[1], 0xD8);
  });

  test('the shape of the photo is kept', () async {
    final decoded = img.decodeImage(
      (await shrinker.shrink(_jpeg(2000, 1000)))!,
    )!;
    expect(decoded.width / decoded.height, closeTo(2, 0.02));
  });

  test('a small photo is not blown up', () async {
    final decoded = img.decodeImage((await shrinker.shrink(_jpeg(200, 300)))!)!;
    expect(decoded.width, 200);
    expect(decoded.height, 300);
  });

  test('a PNG (a saved scan photo) becomes a JPEG too', () async {
    final result = (await shrinker.shrink(_png(1600, 1200)))!;
    expect(result[0], 0xFF);
    expect(img.decodeImage(result)!.width, ImagePhotoShrinker.longSide);
  });

  test('the result is small enough to send', () async {
    final result = (await shrinker.shrink(_jpeg(3000, 4000)))!;
    expect(result.length, lessThan(1_500_000));
  });

  test('something that is not a picture gives nothing back', () async {
    expect(await shrinker.shrink(Uint8List.fromList([1, 2, 3, 4])), isNull);
    expect(await shrinker.shrink(Uint8List(0)), isNull);
  });
}
