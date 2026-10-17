import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/services/before_after_gif.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/domain/repositories/scan_history_repository.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

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

  /// What changed, or null until Saaf AI has analysed both scans (the screen
  /// then shows the photos but no numbers).
  final Progress? progress;
  final CompletedScan before;
  final CompletedScan after;

  /// The very first scan, for "week N" and the AI review.
  final CompletedScan first;

  int get week => weekNumber(first.takenAt, after.takenAt);
}

/// The comparison, or null while there are fewer than two scans. Its numbers
/// come only from Saaf AI's estimates of the two scans' photos.
@Riverpod(retry: noAutoRetry)
Future<ProgressView?> progressView(Ref ref) async {
  final history = ref.watch(scanHistoryProvider);
  if (history.length < 2) return null;

  final before = history[history.length - 2];
  final after = history.last;
  final estimates = await ref.watch(aiSkinEstimatesProvider.future);
  final beforeAnalysis = analysisOf(before, estimates);
  final afterAnalysis = analysisOf(after, estimates);

  return ProgressView(
    progress: beforeAnalysis == null || afterAnalysis == null
        ? null
        : const CompareProgress()(before: beforeAnalysis, after: afterAnalysis),
    before: before,
    after: after,
    first: history.first,
  );
}

/// The front photo of the last finished scan, for lining up the next one;
/// null before the first scan.
@riverpod
Future<Uint8List?> lastFrontPhoto(Ref ref) async {
  final history = ref.watch(scanHistoryProvider);
  if (history.isEmpty) return null;
  final front = frontPhotoOf(history.last);
  if (front == null) return null;
  return (await ref.watch(photoStoreProvider).load(front)).valueOrNull;
}

/// The before-and-after animation of two front photos (made on the phone, in
/// the background); null when a photo cannot be read.
Future<Uint8List?> makeProgressAnimation({
  required Uint8List before,
  required Uint8List after,
  required String beforeLabel,
  required String afterLabel,
}) => compute(
  makeBeforeAfterGif,
  BeforeAfterFrames(
    before: before,
    after: after,
    beforeLabel: beforeLabel,
    afterLabel: afterLabel,
  ),
);
