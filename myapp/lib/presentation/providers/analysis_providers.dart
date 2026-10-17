import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/ai_skin_estimate_json.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/demo_skin_analyzer.dart';
import 'package:saaf/data/services/plugin_share_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/services/share_service.dart';
import 'package:saaf/domain/services/skin_analyzer.dart';
import 'package:saaf/domain/usecases/analyse_scan.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'analysis_providers.g.dart';

/// PLACEHOLDER analyser (estimates from the quiz answers) until real on-device
/// image analysis exists; swap it here (see handoff.md).
@Riverpod(keepAlive: true)
SkinAnalyzer skinAnalyzer(Ref ref) => const DemoSkinAnalyzer();

@Riverpod(keepAlive: true)
AnalyseScan analyseScan(Ref ref) =>
    AnalyseScan(ref.watch(skinAnalyzerProvider));

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) =>
    Env.fakeCamera ? FakeShareService() : PluginShareService();

/// The results for the latest finished scan; null when there is none yet.
/// Saaf AI's estimate from the photo when the user asked for one, otherwise
/// the starting guess from the quiz (the screen says which). A failure
/// surfaces as an error state the screen can retry.
@Riverpod(retry: noAutoRetry)
Future<SkinAnalysis?> skinAnalysis(Ref ref) async {
  final scan = ref.watch(completedScanProvider);
  if (scan == null) return null;
  final estimates = await ref.watch(aiSkinEstimatesProvider.future);
  final estimate = estimates[scan.id];
  if (estimate != null && estimate.usable) {
    return estimate.toAnalysis(scanId: scan.id, takenAt: scan.takenAt);
  }
  final profile = ref.watch(skinProfileControllerProvider);
  final result = await ref.watch(analyseScanProvider)(scan, profile);
  return result.when(
    ok: (analysis) => analysis,
    err: (failure) => throw failure,
  );
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
