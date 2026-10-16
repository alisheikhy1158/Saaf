import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/photo_picker.dart';

/// The system photo picker through `image_picker`. Photos are scaled down to
/// 1080 px and JPEG quality 85 as they are chosen (PERF-3).
class PluginPhotoPicker implements PhotoPicker {
  /// [pick] is replaceable so tests need no phone.
  PluginPhotoPicker({Future<XFile?> Function()? pick})
    : _pick = pick ?? _gallery;

  final Future<XFile?> Function() _pick;

  static Future<XFile?> _gallery() => ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1080,
    maxHeight: 1080,
    imageQuality: 85,
  );

  @override
  Future<Result<Uint8List?>> pickFromGallery() async {
    try {
      final file = await _pick();
      if (file == null) return const Ok<Uint8List?>(null);
      return Ok<Uint8List?>(await file.readAsBytes());
    } on PlatformException catch (e) {
      return Err(
        e.code.contains('denied')
            ? const PermissionDenied()
            : UnknownFailure(e.code),
      );
    } on Object {
      return const Err(UnknownFailure('pick'));
    }
  }
}
