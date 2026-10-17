import 'dart:typed_data';

import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/real_product_catalog.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';

/// A pretend AI coach for Chrome, tests and builds without the real service. It
/// always says it is a demo, so nobody mistakes it for real advice.
class FakeAiCoachService implements AiCoachService {
  const FakeAiCoachService();

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async => Ok(
    'This is a demo answer: the real AI coach is not connected in this '
    'build. It would reply here about "${question.isEmpty ? 'your photo' : question}"'
    '${context.skinType == null ? '' : ' for ${context.skinType!.name} skin'}.',
  );

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async => const Ok<void>(null);
}

/// A sign-in token that always exists (for the fake backend).
class FakeAuthTokenProvider implements AuthTokenProvider {
  const FakeAuthTokenProvider();

  @override
  Future<String?> idToken() async => 'demo-token';
}

/// Hands back a demo photo, as if the user had taken or chosen one.
class FakeAiPhotoPicker implements AiPhotoPicker {
  const FakeAiPhotoPicker();

  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async =>
      Ok(solidPng(width: 24, height: 32, red: 184, green: 156, blue: 132));
}

/// Pretend product help for Chrome and builds without the real service. Like
/// the pretend coach it always says it is a demo.
class FakeAiProductService implements AiProductService {
  const FakeAiProductService();

  @override
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<OwnedProduct> currentProducts,
    Map<SkinMetricKind, double> scan = const {},
  }) async {
    final firstPerStep = <ProductCategory, Product>{};
    for (final product in RealProductCatalog.products) {
      firstPerStep.putIfAbsent(product.category, () => product);
    }
    return Ok(
      AiRoutinePlan(
        summary: 'Demo picks: the real Saaf AI is not connected in this build.',
        picks: [
          for (final product in firstPerStep.values)
            AiPick(product: product, brand: '', why: 'A demo reason.'),
        ],
        current: [
          for (final owned in currentProducts)
            CurrentProductReview(
              name: owned.name,
              verdict: ProductVerdict.keep,
              why: 'A demo verdict.',
            ),
        ],
      ),
    );
  }

  @override
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  }) async => const Ok(
    ProductInsight(
      title: 'Demo product',
      text:
          'This is a demo answer: the real Saaf AI is not connected in this '
          'build.\n**What it is**\n- A product it would look up on the web.',
      webChecked: false,
    ),
  );
}

/// A pretend skin estimate for Chrome and builds without the real service. It
/// says it is a demo and is never sure.
class FakeAiSkinService implements AiSkinService {
  const FakeAiSkinService();

  @override
  Future<Result<AiSkinEstimate>> estimateSkin({
    required Uint8List photo,
    required String languageCode,
  }) async => Ok(
    AiSkinEstimate(
      usable: true,
      summary:
          'Demo estimate: the real Saaf AI is not connected in this build.',
      metrics: [
        for (final kind in SkinMetricKind.values)
          SkinMetric(kind: kind, amount: 0.5, confidence: Confidence.low),
      ],
    ),
  );
}
