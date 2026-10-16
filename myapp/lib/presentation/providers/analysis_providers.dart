import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/demo_skin_analyzer.dart';
import 'package:saaf/data/services/plugin_share_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/services/share_service.dart';
import 'package:saaf/domain/services/skin_analyzer.dart';
import 'package:saaf/domain/usecases/analyse_scan.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
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

/// A failed analysis shows at once with a "Try again" button instead of being
/// retried behind the user's back.
Duration? _noAutoRetry(int retryCount, Object error) => null;

/// The results for the latest finished scan; null when there is none yet.
/// A failure surfaces as an error state the screen can retry.
@Riverpod(retry: _noAutoRetry)
Future<SkinAnalysis?> skinAnalysis(Ref ref) async {
  final scan = ref.watch(completedScanProvider);
  if (scan == null) return null;
  final profile = ref.watch(skinProfileControllerProvider);
  final result = await ref.watch(analyseScanProvider)(scan, profile);
  return result.when(
    ok: (analysis) => analysis,
    err: (failure) => throw failure,
  );
}
