import 'package:saaf/domain/entities/completed_scan.dart';

/// The finished face scans (the photos are files in private storage; this keeps
/// which scans exist and where their photos are).
abstract interface class ScanHistoryRepository {
  /// Oldest first.
  Future<List<CompletedScan>> all();

  Future<void> add(CompletedScan scan);
}
