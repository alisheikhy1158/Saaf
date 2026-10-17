import 'dart:typed_data';

import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';

/// Sends the front photo to Saaf AI for an estimate. The screen has already
/// shown the user the photo and asked; this still refuses without the saved
/// permission. Only the photo and the language go along.
class EstimateSkin {
  const EstimateSkin({
    required AiSkinService service,
    required AiConsent consent,
  }) : _service = service,
       _consent = consent;

  final AiSkinService _service;
  final AiConsent _consent;

  Future<Result<AiSkinEstimate>> call({
    required Uint8List photo,
    required String languageCode,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());
    if (photo.isEmpty) return const Err(ValidationFailure('photo'));
    try {
      return await _service.estimateSkin(
        photo: photo,
        languageCode: languageCode,
      );
    } on Object {
      return const Err(UnknownFailure('ai-skin'));
    }
  }
}
