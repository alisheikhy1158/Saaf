// Covers: the report for the user's dermatologist — their skin facts, the
// latest AI estimate (with how sure it is), routine and products; made on the
// phone, never with the safety answers; and the dermatologist search link
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/dermatologist_search.dart';
import 'package:saaf/data/services/doctor_report_pdf.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/doctor_report.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';

DoctorReport _report() => DoctorReport.from(
  createdOn: DateTime(2026, 10, 18),
  name: 'Ayesha',
  profile: const SkinProfile(
    skinType: SkinType.oily,
    concerns: {SkinConcern.acne, SkinConcern.darkSpots},
    sensitivity: Sensitivity.sometimes,
    safetyFlags: {
      SafetyFlag.pregnantOrBreastfeeding,
      SafetyFlag.prescriptionTreatment,
    },
  ),
  latest: SkinAnalysis(
    scanId: 's1',
    takenAt: DateTime(2026, 10, 17),
    summary: 'Some shine and a few spots.',
    metrics: const [
      SkinMetric(
        kind: SkinMetricKind.breakouts,
        amount: 0.8,
        confidence: Confidence.high,
        seen: 'Spots on the chin.',
      ),
    ],
  ),
  morning: const ['Neem Face Wash', 'SPF 50'],
  night: const ['Neem Face Wash'],
  products: const [
    OwnedProduct(name: 'Nivea Soft', step: ProductCategory.moisturiser),
  ],
  verdicts: const [
    CurrentProductReview(
      name: 'Nivea Soft',
      verdict: ProductVerdict.replace,
      why: 'Heavy for oily skin.',
    ),
  ],
);

void main() {
  test('says what the doctor needs, in plain lines', () {
    final text = _report().lines.join('\n');
    for (final must in [
      'Ayesha',
      'Skin type: oily',
      'acne',
      'Sensitivity: sometimes reacts',
      'Breakouts: 0.80 (Saaf AI, high confidence)',
      'Spots on the chin.',
      'Morning: Neem Face Wash, SPF 50',
      'Nivea Soft (moisturiser): Saaf AI says replace',
    ]) {
      expect(text, contains(must), reason: must);
    }
  });

  test('never includes the safety answers', () {
    final text = _report().lines.join('\n').toLowerCase();
    for (final word in ['pregnan', 'breastfeed', 'prescription', 'allerg']) {
      expect(text, isNot(contains(word)), reason: word);
    }
  });

  test('without a scan it says the skin was not analysed', () {
    final report = DoctorReport.from(
      createdOn: DateTime(2026, 10, 18),
      profile: const SkinProfile(),
      morning: const [],
      night: const [],
    );
    expect(report.lines.join('\n'), contains('No analysed scan yet'));
  });

  test('the PDF is made on the phone', () async {
    final bytes = await buildDoctorReportPdf(_report());
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('the dermatologist search names the city, or nearby', () {
    expect(
      dermatologistSearchUrl('Lahore'),
      'https://www.google.com/maps/search/?api=1&query=dermatologist+in+Lahore',
    );
    expect(
      dermatologistSearchUrl(null),
      'https://www.google.com/maps/search/?api=1&query=dermatologist+near+me',
    );
  });
}
