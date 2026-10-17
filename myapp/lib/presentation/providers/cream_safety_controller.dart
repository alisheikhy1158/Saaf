import 'dart:typed_data';
import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';

part 'cream_safety_controller.g.dart';

const Object _keep = Object();

class CreamSafetyState {
  const CreamSafetyState({
    this.photo,
    this.photoFailed = false,
    this.checking = false,
    this.check,
    this.failure,
    this.reported = false,
  });

  final Uint8List? photo;
  final bool photoFailed;
  final bool checking;
  final SafetyCheck? check;
  final Failure? failure;
  final bool reported;

  CreamSafetyState copyWith({
    bool? checking,
    Object? check = _keep,
    Object? failure = _keep,
    bool? reported,
    bool? photoFailed,
  }) => CreamSafetyState(
    photo: photo,
    photoFailed: photoFailed ?? this.photoFailed,
    checking: checking ?? this.checking,
    check: identical(check, _keep) ? this.check : check as SafetyCheck?,
    failure: identical(failure, _keep) ? this.failure : failure as Failure?,
    reported: reported ?? this.reported,
  );
}

/// One cream check. Nothing is kept: leaving the screen forgets it.
@riverpod
class CreamSafetyController extends _$CreamSafetyController {
  @override
  CreamSafetyState build() => const CreamSafetyState();

  /// Takes or chooses the label photo; it is only sent by [check].
  Future<void> pickPhoto(AiPhotoSource source) async {
    final result = await ref.read(aiPhotoPickerProvider).pick(source);
    if (!ref.mounted) return;
    switch (result) {
      case Ok(:final value):
        if (value == null) return;
        state = CreamSafetyState(photo: value);
      case Err():
        state = state.copyWith(photoFailed: true);
    }
  }

  Future<void> check(CreamQuery query) async {
    if (state.checking) return;
    state = state.copyWith(checking: true, failure: null, check: null);
    final chosen = ref.read(localeControllerProvider)?.languageCode;
    final language =
        (chosen ?? PlatformDispatcher.instance.locale.languageCode) == 'ur'
        ? 'ur'
        : 'en';
    final result = await ref.read(checkCreamSafetyProvider)(
      query: query,
      languageCode: language,
    );
    if (!ref.mounted) return;
    state = switch (result) {
      Ok(:final value) => state.copyWith(checking: false, check: value),
      Err(:final failure) => state.copyWith(checking: false, failure: failure),
    };
    if (result.failureOrNull is ConsentMissing) {
      await ref.read(aiConsentStateProvider.notifier).withdraw();
    }
  }

  /// Reports the answer (Google Play's AI-content policy). True when sent.
  Future<bool> report(String reason) async {
    final check = state.check;
    if (check == null || state.reported) return false;
    final result = await ref
        .read(aiCoachServiceProvider)
        .report(
          reply: AiMessage(
            id: 'cream-${DateTime.now().millisecondsSinceEpoch}',
            role: AiRole.assistant,
            text: [
              check.title,
              check.level.name,
              check.summary,
              for (final f in check.findings) '${f.text} ${f.source ?? ''}',
            ].join('\n'),
            createdAt: DateTime.now(),
          ),
          reason: reason,
        );
    if (!ref.mounted || !result.isOk) return false;
    state = state.copyWith(reported: true);
    return true;
  }

  void reset() => state = const CreamSafetyState();
}
