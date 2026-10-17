import 'dart:typed_data';
import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'product_insight_controller.g.dart';

const Object _keep = Object();

/// Everything the Saaf AI look-up screen shows.
class ProductInsightState {
  const ProductInsightState({
    this.photo,
    this.photoFailed = false,
    this.searching = false,
    this.insight,
    this.failure,
    this.reported = false,
  });

  /// The label photo waiting to be sent (photo look-ups only).
  final Uint8List? photo;
  final bool photoFailed;
  final bool searching;

  /// The answer; null until there is one.
  final ProductInsight? insight;
  final Failure? failure;
  final bool reported;

  ProductInsightState copyWith({
    Object? photo = _keep,
    bool? photoFailed,
    bool? searching,
    Object? insight = _keep,
    Object? failure = _keep,
    bool? reported,
  }) => ProductInsightState(
    photo: identical(photo, _keep) ? this.photo : photo as Uint8List?,
    photoFailed: photoFailed ?? this.photoFailed,
    searching: searching ?? this.searching,
    insight: identical(insight, _keep)
        ? this.insight
        : insight as ProductInsight?,
    failure: identical(failure, _keep) ? this.failure : failure as Failure?,
    reported: reported ?? this.reported,
  );
}

/// One Saaf AI product look-up. Nothing is kept: leaving the screen forgets
/// the photo and the answer.
@riverpod
class ProductInsightController extends _$ProductInsightController {
  @override
  ProductInsightState build() => const ProductInsightState();

  /// Takes or chooses the label photo; it is only sent by [lookUp].
  Future<void> pickPhoto(AiPhotoSource source) async {
    final result = await ref.read(aiPhotoPickerProvider).pick(source);
    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        if (value == null) return; // cancelled
        state = ProductInsightState(photo: value);
      case Err():
        state = state.copyWith(photoFailed: true);
    }
  }

  Future<void> lookUp(ProductQuery query) async {
    if (state.searching) return;
    state = state.copyWith(searching: true, failure: null, insight: null);
    final chosen = ref.read(localeControllerProvider)?.languageCode;
    final language =
        (chosen ?? PlatformDispatcher.instance.locale.languageCode) == 'ur'
        ? 'ur'
        : 'en';
    final result = await ref.read(lookUpProductProvider)(
      query: query,
      profile: ref.read(skinProfileControllerProvider),
      languageCode: language,
    );
    if (!ref.mounted) return;
    state = switch (result) {
      Ok(:final value) => state.copyWith(searching: false, insight: value),
      Err(:final failure) => state.copyWith(searching: false, failure: failure),
    };
    if (result.failureOrNull is ConsentMissing) {
      await ref.read(aiConsentStateProvider.notifier).withdraw();
    }
  }

  /// Reports the answer (Google Play's AI-content policy). True when sent.
  Future<bool> report(String reason) async {
    final insight = state.insight;
    if (insight == null || !insight.found || state.reported) return false;
    final result = await ref
        .read(aiCoachServiceProvider)
        .report(
          reply: AiMessage(
            id: 'product-${DateTime.now().millisecondsSinceEpoch}',
            role: AiRole.assistant,
            text: '${insight.title ?? ''}\n${insight.text}'.trim(),
            createdAt: DateTime.now(),
          ),
          reason: reason,
        );
    if (!ref.mounted || !result.isOk) return false;
    state = state.copyWith(reported: true);
    return true;
  }

  /// Back to the start (a new photo).
  void reset() => state = const ProductInsightState();
}
