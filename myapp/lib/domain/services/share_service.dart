import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';

/// A file the user chose to share (their progress animation, a report for
/// their doctor).
class SharedFile {
  const SharedFile({
    required this.bytes,
    required this.mimeType,
    required this.fileName,
  });

  final Uint8List bytes;
  final String mimeType;
  final String fileName;
}

/// Opens the phone's share sheet: text, or a file the user made and chose to
/// share (their progress animation, a report for their doctor); never without
/// a tap.
abstract interface class ShareService {
  Future<Result<void>> shareText(String text);

  Future<Result<void>> shareFile(SharedFile file, {String? text});
}
