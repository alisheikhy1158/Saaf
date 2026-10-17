import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/ai_skin_estimate_json.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/plugin_share_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/services/share_service.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';

part 'analysis_providers.g.dart';

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) =>
    Env.fakeCamera ? FakeShareService() : PluginShareService();

/// The results for the latest finished scan: Saaf AI's estimate from its
/// front photo. Null when there is no scan, or the scan has not been analysed
/// yet; the app never shows numbers that were not read from the photo.
@Riverpod(retry: noAutoRetry)
Future<SkinAnalysis?> skinAnalysis(Ref ref) async {
  final scan = ref.watch(completedScanProvider);
  if (scan == null) return null;
  final estimates = await ref.watch(aiSkinEstimatesProvider.future);
  return analysisOf(scan, estimates);
}

/// [scan]'s results from Saaf AI's estimate, or null when it has none.
SkinAnalysis? analysisOf(
  CompletedScan scan,
  Map<String, AiSkinEstimate> estimates,
) {
  final estimate = estimates[scan.id];
  return estimate != null && estimate.usable
      ? estimate.toAnalysis(scanId: scan.id, takenAt: scan.takenAt)
      : null;
}

/// Saaf AI's skin estimates, by scan id, kept on the phone. Only usable ones
/// are kept. [analyse] sends a scan's front photo (after the screen asked).
@Riverpod(keepAlive: true)
class AiSkinEstimates extends _$AiSkinEstimates {
  @override
  Future<Map<String, AiSkinEstimate>> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.aiSkinEstimates);
    if (json == null) return const {};
    try {
      final data = jsonDecode(json);
      if (data is! Map<String, Object?>) return const {};
      return {
        for (final MapEntry(:key, :value) in data.entries)
          if (AiSkinEstimateJson.decode(value) case final estimate?
              when estimate.usable)
            key: estimate,
      };
    } on Object {
      return const {};
    }
  }

  /// Sends [scan]'s front photo to Saaf AI. The estimate (usable or not), or
  /// why it could not be had.
  Future<Result<AiSkinEstimate>> analyse(
    CompletedScan scan, {
    required String languageCode,
  }) async {
    final front = frontPhotoOf(scan);
    if (front == null) return const Err(ValidationFailure('photo'));
    final stored = await ref.read(photoStoreProvider).load(front);
    final bytes = stored.valueOrNull;
    if (bytes == null) return Err(stored.failureOrNull!);
    final small = await ref.read(photoShrinkerProvider).shrink(bytes);
    if (small == null) return const Err(ValidationFailure('photo'));

    final result = await ref.read(estimateSkinProvider)(
      photo: small,
      languageCode: languageCode,
    );
    final estimate = result.valueOrNull;
    if (estimate != null && estimate.usable && ref.mounted) {
      final now = {...await future, scan.id: estimate};
      await ref
          .read(settingsRepositoryProvider)
          .write(
            SettingNames.aiSkinEstimates,
            jsonEncode({
              for (final MapEntry(:key, :value) in now.entries)
                key: AiSkinEstimateJson.encode(value),
            }),
          );
      state = AsyncData(now);
    }
    if (result.failureOrNull is ConsentMissing) {
      await ref.read(aiConsentStateProvider.notifier).withdraw();
    }
    return result;
  }
}

/// Whether each new scan's front photo goes to Saaf AI by itself: null until
/// the user has been asked (once), then their answer. Saaf AI sharing must
/// also be on; the switch is in Profile.
@Riverpod(keepAlive: true)
class AutoAnalyseScans extends _$AutoAnalyseScans {
  @override
  Future<bool?> build() async {
    final value = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.autoAnalyseScans);
    return switch (value) {
      'on' => true,
      'off' => false,
      _ => null,
    };
  }

  Future<void> set({required bool on}) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.autoAnalyseScans, on ? 'on' : 'off');
    state = AsyncData(on);
  }
}
