// Covers: demo photos for the fake camera (Chrome / tests) — a valid PNG made in
// pure Dart (no dart:io, so it works on web)
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/solid_png.dart';

void main() {
  test('starts with the PNG signature and ends with IEND', () {
    final png = solidPng(width: 4, height: 6, red: 1, green: 2, blue: 3);
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    expect(
      String.fromCharCodes(png.sublist(png.length - 8, png.length - 4)),
      'IEND',
    );
  });

  test('the header records the size', () {
    final png = solidPng(width: 40, height: 60, red: 0, green: 0, blue: 0);
    final data = ByteData.sublistView(png);
    expect(String.fromCharCodes(png.sublist(12, 16)), 'IHDR');
    expect(data.getUint32(16), 40);
    expect(data.getUint32(20), 60);
  });

  test('different sizes and colours give different bytes', () {
    expect(
      solidPng(width: 4, height: 4, red: 1, green: 1, blue: 1),
      isNot(solidPng(width: 4, height: 4, red: 2, green: 1, blue: 1)),
    );
    expect(
      solidPng(width: 4, height: 4, red: 1, green: 1, blue: 1).length,
      lessThan(
        solidPng(width: 64, height: 64, red: 1, green: 1, blue: 1).length,
      ),
    );
  });

  test('rejects sizes that are not positive', () {
    expect(
      () => solidPng(width: 0, height: 4, red: 0, green: 0, blue: 0),
      throwsArgumentError,
    );
    expect(
      () => solidPng(width: 4, height: -1, red: 0, green: 0, blue: 0),
      throwsArgumentError,
    );
  });

  testWidgets('Flutter can decode it, with the right size and colour', (
    tester,
  ) async {
    final png = solidPng(width: 8, height: 12, red: 204, green: 213, blue: 174);
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 8);
      expect(frame.image.height, 12);
      final pixels = (await frame.image.toByteData())!;
      expect(
        [pixels.getUint8(0), pixels.getUint8(1), pixels.getUint8(2)],
        [204, 213, 174],
      );
    });
  });
}
