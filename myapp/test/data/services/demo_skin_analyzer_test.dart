// Covers: 07 Analysis results — the PLACEHOLDER analyser that estimates from the
// quiz answers until on-device image analysis exists (see handoff.md)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/demo_skin_analyzer.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';

final _scan = CompletedScan(
  id: 'scan-9',
  takenAt: DateTime.utc(2026, 10, 15, 9, 41),
  photos: const [],
);

Future<SkinAnalysis> analyse(SkinProfile profile) async {
  final result = await const DemoSkinAnalyzer().analyze(
    scan: _scan,
    profile: profile,
  );
  return result.valueOrNull!;
}

double amountOf(SkinAnalysis a, SkinMetricKind kind) =>
    a.metrics.firstWhere((m) => m.kind == kind).amount;

void main() {
  test(
    'keeps the scan id and time, and the four measures in screen order',
    () async {
      final a = await analyse(const SkinProfile());
      expect(a.scanId, 'scan-9');
      expect(a.takenAt, _scan.takenAt);
      expect(a.metrics.map((m) => m.kind), SkinMetricKind.values);
    },
  );

  test('knowing nothing gives a gentle middle-of-the-road result', () async {
    final a = await analyse(const SkinProfile());
    expect(a.score, inInclusiveRange(70, 90));
    expect(a.tone, SkinTone.good);
  });

  test('the same answers always give the same result', () async {
    const profile = SkinProfile(
      skinType: SkinType.combination,
      concerns: {SkinConcern.acne},
    );
    final a = await analyse(profile);
    final b = await analyse(profile);
    expect(a.score, b.score);
    expect(
      a.metrics.map((m) => m.amount).toList(),
      b.metrics.map((m) => m.amount).toList(),
    );
  });

  group('what the user said they worry about', () {
    test('dark spots raise the dark-spots bar', () async {
      final base = await analyse(const SkinProfile());
      final worried = await analyse(
        const SkinProfile(concerns: {SkinConcern.darkSpots}),
      );
      expect(
        amountOf(worried, SkinMetricKind.darkSpots),
        greaterThan(amountOf(base, SkinMetricKind.darkSpots)),
      );
    });

    test('acne raises the breakouts bar', () async {
      final base = await analyse(const SkinProfile());
      final worried = await analyse(
        const SkinProfile(concerns: {SkinConcern.acne}),
      );
      expect(
        amountOf(worried, SkinMetricKind.breakouts),
        greaterThan(amountOf(base, SkinMetricKind.breakouts)),
      );
    });

    test('oiliness raises the oiliness bar', () async {
      final base = await analyse(const SkinProfile());
      final worried = await analyse(
        const SkinProfile(concerns: {SkinConcern.oiliness}),
      );
      expect(
        amountOf(worried, SkinMetricKind.oiliness),
        greaterThan(amountOf(base, SkinMetricKind.oiliness)),
      );
    });

    test('dryness lowers hydration', () async {
      final base = await analyse(const SkinProfile());
      final worried = await analyse(
        const SkinProfile(concerns: {SkinConcern.dryness}),
      );
      expect(
        amountOf(worried, SkinMetricKind.hydration),
        lessThan(amountOf(base, SkinMetricKind.hydration)),
      );
    });

    test('uneven tone also nudges dark spots up', () async {
      final base = await analyse(const SkinProfile());
      final worried = await analyse(
        const SkinProfile(concerns: {SkinConcern.unevenTone}),
      );
      expect(
        amountOf(worried, SkinMetricKind.darkSpots),
        greaterThan(amountOf(base, SkinMetricKind.darkSpots)),
      );
    });

    test('the two things picked become the focus', () async {
      final a = await analyse(
        const SkinProfile(concerns: {SkinConcern.darkSpots, SkinConcern.acne}),
      );
      expect(a.focus.map((m) => m.kind).toSet(), {
        SkinMetricKind.darkSpots,
        SkinMetricKind.breakouts,
      });
    });
  });

  group('skin type', () {
    test('oily skin shows more oil', () async {
      final base = await analyse(const SkinProfile());
      final oily = await analyse(const SkinProfile(skinType: SkinType.oily));
      expect(
        amountOf(oily, SkinMetricKind.oiliness),
        greaterThan(amountOf(base, SkinMetricKind.oiliness)),
      );
    });

    test('dry skin shows less oil and less hydration', () async {
      final base = await analyse(const SkinProfile());
      final dry = await analyse(const SkinProfile(skinType: SkinType.dry));
      expect(
        amountOf(dry, SkinMetricKind.oiliness),
        lessThan(amountOf(base, SkinMetricKind.oiliness)),
      );
      expect(
        amountOf(dry, SkinMetricKind.hydration),
        lessThan(amountOf(base, SkinMetricKind.hydration)),
      );
    });

    test('every skin type gives a valid result', () async {
      for (final type in SkinType.values) {
        final a = await analyse(SkinProfile(skinType: type));
        expect(a.score, inInclusiveRange(0, 100), reason: '$type');
      }
    });
  });

  test('piling everything on stays inside the 0–1 range', () async {
    final a = await analyse(
      const SkinProfile(
        skinType: SkinType.oily,
        concerns: {SkinConcern.darkSpots, SkinConcern.acne},
        sensitivity: Sensitivity.high,
      ),
    );
    for (final m in a.metrics) {
      expect(m.amount, inInclusiveRange(0.05, 0.95), reason: '${m.kind}');
    }
  });

  test('worrying concerns lower the score', () async {
    final base = await analyse(const SkinProfile());
    final worried = await analyse(
      const SkinProfile(
        skinType: SkinType.oily,
        concerns: {SkinConcern.darkSpots, SkinConcern.acne},
      ),
    );
    expect(worried.score, lessThan(base.score));
  });
}
