import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';

/// Photos for the AI coach through the system camera or gallery
/// (`image_picker`). They are scaled down to 1024 px and JPEG quality 80 as
/// they are chosen, which keeps the upload small and fast.
class PluginAiPhotoPicker implements AiPhotoPicker {
  PluginAiPhotoPicker({Future<XFile?> Function(ImageSource source)? pick})
    : _pick = pick ?? _system;

  final Future<XFile?> Function(ImageSource source) _pick;

  static Future<XFile?> _system(ImageSource source) => ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 80,
  );

  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async {
    try {
      final file = await _pick(
        source == AiPhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (file == null) return const Ok<Uint8List?>(null);
      return Ok<Uint8List?>(await file.readAsBytes());
    } on PlatformException catch (e) {
      return Err(
        e.code.contains('denied')
            ? const PermissionDenied()
            : UnknownFailure(e.code),
      );
    } on Object {
      return const Err(UnknownFailure('ai-photo'));
    }
  }
}
