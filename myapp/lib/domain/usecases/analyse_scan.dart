import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/services/skin_analyzer.dart';

/// Analyses a finished scan together with what the user said in the quiz.
class AnalyseScan {
  const AnalyseScan(this._analyzer);

  final SkinAnalyzer _analyzer;

  Future<Result<SkinAnalysis>> call(
    CompletedScan scan,
    SkinProfile profile,
  ) async {
    try {
      return await _analyzer.analyze(scan: scan, profile: profile);
    } on Object {
      return const Err(UnknownFailure('analyse'));
    }
  }
}
