import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/data/services/doctor_report_pdf.dart';
import 'package:saaf/domain/entities/doctor_report.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

/// Makes the PDF report for the user's dermatologist from what the app knows
/// (on the phone; it is only shared when the user taps).
Future<Uint8List> makeDoctorReport(WidgetRef ref) async {
  final scan = ref.read(completedScanProvider);
  SkinAnalysis? latest;
  try {
    latest = await ref.read(skinAnalysisProvider.future);
  } on Object {
    // No analysis: the report says so.
  }
  Uint8List? photo;
  if (scan != null && latest != null) {
    if (frontPhotoOf(scan) case final front?) {
      photo = (await ref.read(photoStoreProvider).load(front)).valueOrNull;
    }
  }
  var routine = const Routine(morning: [], night: []);
  try {
    routine = await ref.read(routineProvider.future);
  } on Object {
    // No routine yet.
  }
  final report = DoctorReport.from(
    createdOn: ref.read(clockProvider).now(),
    name: ref.read(profileDetailsControllerProvider).name,
    profile: ref.read(skinProfileControllerProvider),
    latest: latest,
    frontPhoto: photo,
    morning: [for (final s in routine.morning) s.product.name],
    night: [for (final s in routine.night) s.product.name],
    products: await ref.read(currentProductsProvider.future),
    verdicts:
        ref.read(aiRoutinePlanControllerProvider).value?.current ?? const [],
  );
  return buildDoctorReportPdf(report);
}
