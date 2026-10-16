import 'dart:typed_data';

/// A valid single-colour PNG, made in pure Dart (no dart:io, no dependencies), so
/// the fake camera can hand out demo photos in Chrome and in tests. The pixel
/// data is stored uncompressed (zlib "stored" blocks); the images are tiny.
Uint8List solidPng({
  required int width,
  required int height,
  required int red,
  required int green,
  required int blue,
}) {
  if (width <= 0 || height <= 0) {
    throw ArgumentError('width and height must be positive');
  }

  // One scanline = filter byte 0 + RGB per pixel.
  final row = Uint8List(1 + width * 3);
  for (var x = 0; x < width; x++) {
    row[1 + x * 3] = red;
    row[2 + x * 3] = green;
    row[3 + x * 3] = blue;
  }
  final raw = BytesBuilder(copy: false);
  for (var y = 0; y < height; y++) {
    raw.add(row);
  }

  final out = BytesBuilder(copy: false)
    ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2) // colour type: RGB
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  _chunk(out, 'IHDR', header.buffer.asUint8List());
  _chunk(out, 'IDAT', _zlibStored(raw.takeBytes()));
  _chunk(out, 'IEND', Uint8List(0));
  return out.takeBytes();
}

void _chunk(BytesBuilder out, String type, Uint8List data) {
  final length = ByteData(4)..setUint32(0, data.length);
  out.add(length.buffer.asUint8List());
  final typeAndData = Uint8List(4 + data.length)
    ..setRange(0, 4, type.codeUnits)
    ..setRange(4, 4 + data.length, data);
  out.add(typeAndData);
  final crc = ByteData(4)..setUint32(0, _crc32(typeAndData));
  out.add(crc.buffer.asUint8List());
}

/// zlib stream made of "stored" (uncompressed) deflate blocks.
Uint8List _zlibStored(Uint8List data) {
  final out = BytesBuilder(copy: false)..add(const [0x78, 0x01]);
  const maxBlock = 65535;
  var offset = 0;
  do {
    final size = data.length - offset > maxBlock
        ? maxBlock
        : data.length - offset;
    final isLast = offset + size >= data.length;
    final header = ByteData(5)
      ..setUint8(0, isLast ? 1 : 0)
      ..setUint16(1, size, Endian.little)
      ..setUint16(3, size ^ 0xFFFF, Endian.little);
    out
      ..add(header.buffer.asUint8List())
      ..add(Uint8List.sublistView(data, offset, offset + size));
    offset += size;
  } while (offset < data.length);

  final adler = ByteData(4)..setUint32(0, _adler32(data));
  out.add(adler.buffer.asUint8List());
  return out.takeBytes();
}

/// The CRC-32 polynomial (0xEDB88320, reflected) and the 32-bit all-ones mask,
/// written in decimal so they are not mistaken for colour codes.
const int _crcPolynomial = 3988292384;
const int _mask32 = 4294967295;

final List<int> _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? _crcPolynomial ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(Uint8List bytes) {
  var c = _mask32;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ _mask32;
}

int _adler32(Uint8List bytes) {
  const mod = 65521;
  var a = 1;
  var b = 0;
  for (final byte in bytes) {
    a = (a + byte) % mod;
    b = (b + a) % mod;
  }
  return (b << 16) | a;
}
