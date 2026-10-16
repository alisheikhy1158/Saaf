import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/domain/services/photo_picker.dart';

/// Hands back a demo photo, as if the user had chosen one from the gallery.
class FakePhotoPicker implements PhotoPicker {
  @override
  Future<Result<Uint8List?>> pickFromGallery() async =>
      Ok(solidPng(width: 24, height: 32, red: 184, green: 156, blue: 132));
}
