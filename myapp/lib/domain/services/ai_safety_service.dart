import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/safety_check.dart';

/// Saaf AI checking a cream for harmful ingredients and reported warnings,
/// through our own server (it reads the label and searches the web).
abstract interface class AiSafetyService {
  Future<Result<SafetyCheck>> checkSafety({
    required CreamQuery query,
    required AiContext context,
  });
}
