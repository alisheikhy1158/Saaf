// Covers: 07 Analysis results use case — errors become Failures (architecture §3.10)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/skin_analyzer.dart';
import 'package:saaf/domain/usecases/analyse_scan.dart';

class _Analyzer implements SkinAnalyzer {
  _Analyzer(this.result);
  final Future<Result<SkinAnalysis>> Function() result;
  CompletedScan? seenScan;
  SkinProfile? seenProfile;

  @override
  Future<Result<SkinAnalysis>> analyze({
    required CompletedScan scan,
    required SkinProfile profile,
  }) {
    seenScan = scan;
    seenProfile = profile;
    return result();
  }
}

final _scan = CompletedScan(
  id: 'scan-1',
  takenAt: DateTime.utc(2026, 10, 15),
  photos: const [],
);
final _analysis = SkinAnalysis(
  scanId: 'scan-1',
  takenAt: DateTime.utc(2026, 10, 15),
  metrics: const [],
);

void main() {
  test('passes the scan and the quiz answers to the analyser', () async {
    final analyzer = _Analyzer(() async => Ok(_analysis));
    const profile = SkinProfile();
    final result = await AnalyseScan(analyzer)(_scan, profile);
    expect(result.valueOrNull, same(_analysis));
    expect(analyzer.seenScan, same(_scan));
    expect(analyzer.seenProfile, same(profile));
  });

  test('passes a failure through', () async {
    final analyzer = _Analyzer(() async => const Err(NetworkFailure()));
    final result = await AnalyseScan(analyzer)(_scan, const SkinProfile());
    expect(result.failureOrNull, const NetworkFailure());
  });

  test('an exception becomes an UnknownFailure', () async {
    final analyzer = _Analyzer(() async => throw StateError('boom'));
    final result = await AnalyseScan(analyzer)(_scan, const SkinProfile());
    expect(result.failureOrNull, const UnknownFailure('analyse'));
  });
}
