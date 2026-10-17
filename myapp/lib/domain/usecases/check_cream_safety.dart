import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/domain/services/ai_safety_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/flag_ingredients.dart';

/// Checks a cream: Saaf AI's verdict (label + web search), then the phone's
/// fixed ingredient rules, which can only make it stricter. A pack that prints
/// no ingredients at all is at least "be careful". Only the photo or the name
/// and the language are sent (nothing about the user's skin or health).
class CheckCreamSafety {
  const CheckCreamSafety({
    required AiSafetyService service,
    required AiConsent consent,
  }) : _service = service,
       _consent = consent;

  final AiSafetyService _service;
  final AiConsent _consent;

  Future<Result<SafetyCheck>> call({
    required CreamQuery query,
    required String languageCode,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());
    final ok = switch (query) {
      CreamPhotoQuery(:final bytes) => bytes.isNotEmpty,
      CreamNameQuery(:final name) => name.trim().isNotEmpty,
    };
    if (!ok) return const Err(ValidationFailure('product'));

    final Result<SafetyCheck> result;
    try {
      result = await _service.checkSafety(
        query: query,
        context: AiContext(languageCode: languageCode),
      );
    } on Object {
      return const Err(UnknownFailure('ai-safety'));
    }
    final check = result.valueOrNull;
    if (check == null || !check.found) return result;

    final flags = const FlagIngredients()(check.ingredients);
    var level = check.level;
    for (final flag in flags) {
      level = _stricter(level, flag.risk.level);
    }
    if (check.ingredientsPrinted == false) {
      level = _stricter(level, SafetyLevel.caution);
    }
    return Ok(check.copyWith(level: level, flags: flags));
  }

  /// danger > caution > no known problem.
  static SafetyLevel _stricter(SafetyLevel a, SafetyLevel b) =>
      a.index <= b.index ? a : b;
}
