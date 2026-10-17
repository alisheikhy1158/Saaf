import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';

/// Saaf AI looking at ONE front photo (already made small on the phone) to
/// estimate the four measures, through our own server. The photo is not kept
/// there.
abstract interface class AiSkinService {
  Future<Result<AiSkinEstimate>> estimateSkin({
    required Uint8List photo,
    required String languageCode,
  });
}
