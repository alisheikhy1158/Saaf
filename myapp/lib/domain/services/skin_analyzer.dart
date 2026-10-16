import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';

/// Turns a finished face scan into the results shown on screen 07. The photos
/// are analysed on the phone and never uploaded (PRV-2).
abstract interface class SkinAnalyzer {
  Future<Result<SkinAnalysis>> analyze({
    required CompletedScan scan,
    required SkinProfile profile,
  });
}
