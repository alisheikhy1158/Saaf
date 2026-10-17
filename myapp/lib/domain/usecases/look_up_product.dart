import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';

/// Asks Saaf AI what a product is and whether it suits the user, from a label
/// photo, a barcode or QR text. Only after consent, with only the non-health
/// facts in [AiContext].
class LookUpProduct {
  const LookUpProduct({
    required AiProductService service,
    required AiConsent consent,
  }) : _service = service,
       _consent = consent;

  final AiProductService _service;
  final AiConsent _consent;

  static final _barcode = RegExp(r'^\d{8,14}$');

  Future<Result<ProductInsight>> call({
    required ProductQuery query,
    required SkinProfile profile,
    required String languageCode,
  }) async {
    if (!await _consent.isGiven()) return const Err(ConsentMissing());

    final ok = switch (query) {
      ProductPhotoQuery(:final bytes) => bytes.isNotEmpty,
      ProductBarcodeQuery(:final digits) => _barcode.hasMatch(digits),
      ProductQrQuery(:final text) => text.trim().isNotEmpty,
    };
    if (!ok) return const Err(ValidationFailure('product'));

    try {
      return await _service.lookUpProduct(
        query: query,
        context: AiContext(
          languageCode: languageCode,
          skinType: profile.skinType,
          concerns: profile.concerns,
          sensitivity: profile.sensitivity,
          budget: profile.budget,
        ),
      );
    } on Object {
      return const Err(UnknownFailure('ai-product'));
    }
  }
}
