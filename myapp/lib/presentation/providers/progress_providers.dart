import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/repositories/scan_history_repository.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'progress_providers.g.dart';

@Riverpod(keepAlive: true)
ScanHistoryRepository scanHistoryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemoryScanHistoryRepository()
      : DriftScanHistoryRepository(db);
}

/// Every finished scan, oldest first. Loaded from the database at start and
/// saved to it as scans finish.
@Riverpod(keepAlive: true)
class ScanHistory extends _$ScanHistory {
  @override
  List<CompletedScan> build() {
    final repository = ref.read(scanHistoryRepositoryProvider);
    repository.all().then((saved) {
      if (ref.mounted && state.isEmpty) state = saved;
    });
    return const [];
  }

  void add(CompletedScan scan) {
    state = [...state, scan];
    ref.read(scanHistoryRepositoryProvider).add(scan);
  }
}

/// The front photo of [scan] (the one the comparison shows).
StoredPhoto? frontPhotoOf(CompletedScan scan) =>
    scan.photos.where((p) => p.pose == FacePose.front).firstOrNull;

/// Photo bytes from private storage; null when the file is gone.
@riverpod
Future<Uint8List?> scanPhotoBytes(Ref ref, StoredPhoto photo) async {
  final result = await ref.watch(photoStoreProvider).load(photo);
  return result.valueOrNull;
}

/// What the Progress tab compares: the latest scan with the one before it (scans
/// are taken every two weeks).
class ProgressView {
  const ProgressView({
    required this.progress,
    required this.before,
    required this.after,
    required this.first,
  });

  final Progress progress;
  final CompletedScan before;
  final CompletedScan after;

  /// The very first scan, for "week N" and the AI review.
  final CompletedScan first;

  int get week => weekNumber(first.takenAt, after.takenAt);
}

/// The comparison, or null while there are fewer than two scans.
@Riverpod(retry: noAutoRetry)
Future<ProgressView?> progressView(Ref ref) async {
  final history = ref.watch(scanHistoryProvider);
  if (history.length < 2) return null;

  final profile = ref.watch(skinProfileControllerProvider);
  final analyse = ref.watch(analyseScanProvider);
  final before = history[history.length - 2];
  final after = history.last;

  // Saaf AI's estimate for a scan when there is one, else the quiz guess.
  final estimates = await ref.watch(aiSkinEstimatesProvider.future);
  Future<Result<SkinAnalysis>> analysed(CompletedScan scan) async {
    final estimate = estimates[scan.id];
    return estimate != null && estimate.usable
        ? Ok(estimate.toAnalysis(scanId: scan.id, takenAt: scan.takenAt))
        : analyse(scan, profile);
  }

  final beforeResult = await analysed(before);
  final afterResult = await analysed(after);
  final beforeAnalysis = beforeResult.when(
    ok: (a) => a,
    err: (failure) => throw failure,
  );
  final afterAnalysis = afterResult.when(
    ok: (a) => a,
    err: (failure) => throw failure,
  );

  return ProgressView(
    progress: const CompareProgress()(
      before: beforeAnalysis,
      after: afterAnalysis,
    ),
    before: before,
    after: after,
    first: history.first,
  );
}
