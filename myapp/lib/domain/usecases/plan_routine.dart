import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';

/// Asks Saaf AI to research a routine on the web and to review the products
/// the user uses now. Only the non-health facts in [AiContext], the scan
/// scores and the product names are sent; the safety answers stay on the
/// phone, where the routine and the verdicts are checked against them
/// (`BuildRoutine`, [CurrentProductReview.cautionFor]).
class PlanRoutine {
  const PlanRoutine({
    required AiProductService service,
    required AiConsent consent,
  }) : _service = service,
       _consent = consent;

  final AiProductService _service;
  final AiConsent _consent;

  Future<Result<AiRoutinePlan>> call({
    required SkinProfile profile,
    required List<String> currentProducts,
    required String languageCode,
    SkinAnalysis? analysis,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());
    try {
      return await _service.planRoutine(
        context: AiContext(
          languageCode: languageCode,
          skinType: profile.skinType,
          concerns: profile.concerns,
          sensitivity: profile.sensitivity,
          budget: profile.budget,
        ),
        currentProducts: currentProducts,
        scan: {
          for (final metric in analysis?.metrics ?? const <SkinMetric>[])
            metric.kind: metric.amount,
        },
      );
    } on Object {
      return const Err(UnknownFailure('ai-routine'));
    }
  }
}
