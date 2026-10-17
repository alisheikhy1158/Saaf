import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_picks.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/build_routine.dart';

/// Asks Saaf AI to choose the routine's products. The safety answers are used
/// HERE, on the phone, to remove products first; Saaf AI only ever sees the
/// products that are left, plus the non-health facts in [AiContext].
class PickProducts {
  const PickProducts({
    required AiProductService service,
    required AiConsent consent,
  }) : _service = service,
       _consent = consent;

  final AiProductService _service;
  final AiConsent _consent;

  /// The server accepts at most this many products to choose from.
  static const maxCandidates = 40;

  Future<Result<ProductPicks>> call({
    required SkinProfile profile,
    required List<Product> catalog,
    required String languageCode,
    SkinAnalysis? analysis,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());

    final candidates = BuildRoutine(catalog).allowedFor(profile);
    if (candidates.isEmpty) return const Err(ValidationFailure('products'));

    try {
      return await _service.pickProducts(
        context: AiContext(
          languageCode: languageCode,
          skinType: profile.skinType,
          concerns: profile.concerns,
          sensitivity: profile.sensitivity,
          budget: profile.budget,
        ),
        candidates: candidates.take(maxCandidates).toList(),
        scan: {
          for (final metric in analysis?.metrics ?? const <SkinMetric>[])
            metric.kind: metric.amount,
        },
      );
    } on Object {
      return const Err(UnknownFailure('ai-picks'));
    }
  }
}
