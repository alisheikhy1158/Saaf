import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';

/// A picture the user chose to share (their own before-and-after animation).
class SharedImage {
  const SharedImage({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

/// Opens the phone's share sheet. Text, or a picture the user made and chose
/// to share (their own progress animation); never anything else from their
/// profile, and never without a tap.
abstract interface class ShareService {
  Future<Result<void>> shareText(String text);

  Future<Result<void>> shareImage(SharedImage image, {String? text});
}
