import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/entities/completed_scan.dart';

part 'completed_scan.g.dart';

/// The most recent finished scan, for the results screen. Becomes a stored scan
/// history with the local database (Phase 7).
@Riverpod(keepAlive: true)
class CompletedScanNotifier extends _$CompletedScanNotifier {
  @override
  CompletedScan? build() => null;

  void set(CompletedScan scan) => state = scan;
}
