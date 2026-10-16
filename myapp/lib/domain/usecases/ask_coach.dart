import 'dart:typed_data';

import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';

/// Sends one question to the AI coach, after checking everything that must be
/// true first: the user gave permission, the message is sensible, and only
/// non-health context goes along.
class AskCoach {
  const AskCoach({required AiCoachService service, required AiConsent consent})
    : _service = service,
      _consent = consent;

  final AiCoachService _service;
  final AiConsent _consent;

  static const maxTextLength = 1000;
  static const maxPhotos = 3;

  /// How many earlier messages are sent along (the latest ones).
  static const maxHistory = 10;

  Future<Result<String>> call({
    required String text,
    required List<Uint8List> photos,
    required List<AiMessage> history,
    required SkinProfile profile,
    required Routine routine,
    required String languageCode,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());

    final question = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (question.length > maxTextLength) {
      return const Err(ValidationFailure('message'));
    }
    if (photos.length > maxPhotos) {
      return const Err(ValidationFailure('photos'));
    }
    if (question.isEmpty && photos.isEmpty) {
      return const Err(ValidationFailure('message'));
    }

    final recent = history.length > maxHistory
        ? history.sublist(history.length - maxHistory)
        : history;

    try {
      return await _service.ask(
        history: recent,
        question: question,
        photos: photos,
        context: AiContext(
          languageCode: languageCode,
          skinType: profile.skinType,
          concerns: profile.concerns,
          sensitivity: profile.sensitivity,
          budget: profile.budget,
          routineProducts: [
            ...{
              for (final step in [...routine.morning, ...routine.night])
                step.product.name,
            },
          ],
        ),
      );
    } on Object {
      return const Err(UnknownFailure('ai-coach'));
    }
  }
}
