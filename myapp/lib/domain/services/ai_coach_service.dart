import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';

/// The AI skin coach: answers questions about skin care and routines, and can
/// look at photos the user attaches. It runs on our own server in front of an
/// open-source model; the app never holds an AI key.
abstract interface class AiCoachService {
  /// Answers [question] (which may be empty when [photos] are attached) given
  /// the chat so far. Fails with `ConsentMissing`, `Unauthorised`,
  /// `RateLimited`, `ServiceUnavailable` or `NetworkFailure`.
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  });

  /// Tells us an AI [reply] was harmful, wrong or offensive (Google Play's AI
  /// content policy asks for this in the app).
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  });
}
