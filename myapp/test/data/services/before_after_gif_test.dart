// Covers: the shareable before-and-after animation (made on the phone, shared
// only when the user taps) — two dated frames of the same size, looping
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/services/before_after_gif.dart';

void main() {
  final before = solidPng(
    width: 600,
    height: 800,
    red: 120,
    green: 90,
    blue: 70,
  );
  final after = solidPng(
    width: 300,
    height: 400,
    red: 160,
    green: 130,
    blue: 110,
  );

  test('two frames, the same size, at most the target width, looping', () {
    final gif = makeBeforeAfterGif(
      BeforeAfterFrames(
        before: before,
        after: after,
        beforeLabel: '14 Sep',
        afterLabel: '14 Oct',
      ),
    );
    expect(gif, isNotNull);
    final decoded = img.decodeGif(gif!)!;
    expect(decoded.numFrames, 2);
    expect(decoded.width, lessThanOrEqualTo(BeforeAfterFrames.width));
    expect(decoded.frames[1].width, decoded.width);
    expect(decoded.loopCount, 0);
  });

  test('an unreadable photo gives no animation', () {
    expect(
      makeBeforeAfterGif(
        BeforeAfterFrames(
          before: before,
          after: solidPng(
            width: 1,
            height: 1,
            red: 0,
            green: 0,
            blue: 0,
          ).sublist(0, 5),
          beforeLabel: 'a',
          afterLabel: 'b',
        ),
      ),
      isNull,
    );
  });
}
