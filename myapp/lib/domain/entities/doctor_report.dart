import 'dart:typed_data';

import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';

/// A short summary for the user's dermatologist, made on the phone and shared
/// only when the user taps. In English (the language of most doctors' notes
/// in Pakistan). It never includes the safety answers: the doctor asks those.
class DoctorReport {
  const DoctorReport._({
    required this.createdOn,
    required this.lines,
    this.frontPhoto,
  });

  factory DoctorReport.from({
    required DateTime createdOn,
    required SkinProfile profile,
    required List<String> morning,
    required List<String> night,
    String? name,
    SkinAnalysis? latest,
    Uint8List? frontPhoto,
    List<OwnedProduct> products = const [],
    List<CurrentProductReview> verdicts = const [],
  }) {
    String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
    final lines = <String>[
      if (name != null && name.trim().isNotEmpty) 'Name: ${name.trim()}',
      'Made on ${date(createdOn)} by the Saaf app.',
      '',
      'About my skin (what I told the app)',
      if (profile.skinType case final type?) 'Skin type: ${_type[type]}',
      if (profile.concerns.isNotEmpty)
        'Main concerns: ${[for (final c in profile.concerns) _concern[c]].join(', ')}',
      if (profile.sensitivity case final s?) 'Sensitivity: ${_sensitivity[s]}',
      '',
      if (latest == null)
        'No analysed scan yet.'
      else ...[
        'Latest scan (${date(latest.takenAt)}): Saaf AI estimate from one front photo. '
            'A cosmetic estimate, not a measurement or diagnosis.',
        ?latest.summary,
        for (final m in latest.metrics)
          '${_metric[m.kind]}: ${m.amount.toStringAsFixed(2)} (Saaf AI, '
              '${(m.confidence ?? Confidence.low).name} confidence)'
              '${m.seen == null ? '' : '. ${m.seen}'}',
      ],
      '',
      'My routine',
      'Morning: ${morning.isEmpty ? 'none' : morning.join(', ')}',
      'Night: ${night.isEmpty ? 'none' : night.join(', ')}',
      if (products.isNotEmpty) ...[
        '',
        'Products I use',
        for (final p in products)
          '${p.name} (${p.step?.name ?? 'other'})'
              '${_verdictFor(verdicts, p.name)}',
      ],
      '',
      'Made by the Saaf app. AI estimates can be wrong; this is not a diagnosis.',
    ];
    return DoctorReport._(
      createdOn: createdOn,
      lines: lines,
      frontPhoto: latest == null ? null : frontPhoto,
    );
  }

  final DateTime createdOn;
  final List<String> lines;

  /// The latest front photo, when there is an analysed scan.
  final Uint8List? frontPhoto;

  static String _verdictFor(List<CurrentProductReview> verdicts, String name) {
    for (final v in verdicts) {
      if (v.name.toLowerCase() == name.toLowerCase()) {
        return ': Saaf AI says ${v.verdict.name}'
            '${v.why.isEmpty ? '' : ' (${v.why})'}';
      }
    }
    return '';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _type = {
    SkinType.oily: 'oily',
    SkinType.dry: 'dry',
    SkinType.combination: 'combination',
    SkinType.normal: 'balanced (normal)',
    SkinType.notSure: 'not sure',
  };
  static const _concern = {
    SkinConcern.darkSpots: 'dark spots and pigmentation',
    SkinConcern.acne: 'acne and breakouts',
    SkinConcern.oiliness: 'oiliness',
    SkinConcern.dryness: 'dryness',
    SkinConcern.unevenTone: 'uneven tone',
    SkinConcern.bodyPigmentation: 'darker underarms, knees or neck',
  };
  static const _sensitivity = {
    Sensitivity.low: 'rarely reacts',
    Sensitivity.sometimes: 'sometimes reacts',
    Sensitivity.high: 'often reacts',
  };
  static const _metric = {
    SkinMetricKind.darkSpots: 'Dark spots',
    SkinMetricKind.breakouts: 'Breakouts',
    SkinMetricKind.oiliness: 'Oiliness',
    SkinMetricKind.hydration: 'Hydration',
  };
}
