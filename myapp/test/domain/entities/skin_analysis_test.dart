// Covers: Figma 07 Analysis results — score, ratings and focus areas
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

SkinAnalysis make({
  double spots = 0.62,
  double breakouts = 0.35,
  double oil = 0.55,
  double hydration = 0.82,
}) => SkinAnalysis(
  scanId: 'scan-1',
  takenAt: DateTime.utc(2026, 10, 15),
  metrics: [
    SkinMetric(kind: SkinMetricKind.darkSpots, amount: spots),
    SkinMetric(kind: SkinMetricKind.breakouts, amount: breakouts),
    SkinMetric(kind: SkinMetricKind.oiliness, amount: oil),
    SkinMetric(kind: SkinMetricKind.hydration, amount: hydration),
  ],
);

void main() {
  group('SkinMetric rating', () {
    test('for a problem, more is worse: mild, moderate, high', () {
      SkinRating rate(double amount) =>
          SkinMetric(kind: SkinMetricKind.breakouts, amount: amount).rating;
      expect(rate(0.0), SkinRating.mild);
      expect(rate(0.35), SkinRating.mild);
      expect(rate(0.4), SkinRating.moderate);
      expect(rate(0.62), SkinRating.moderate);
      expect(rate(0.7), SkinRating.high);
      expect(rate(1.0), SkinRating.high);
    });

    test('for hydration, more is better: low, fair, good', () {
      SkinRating rate(double amount) =>
          SkinMetric(kind: SkinMetricKind.hydration, amount: amount).rating;
      expect(rate(0.2), SkinRating.low);
      expect(rate(0.5), SkinRating.fair);
      expect(rate(0.82), SkinRating.good);
    });

    test('only hydration is a "higher is better" measure', () {
      expect(SkinMetricKind.values.where((k) => k.higherIsBetter), [
        SkinMetricKind.hydration,
      ]);
    });

    test('amount must be between 0 and 1', () {
      expect(
        () => SkinMetric(kind: SkinMetricKind.oiliness, amount: 1.1),
        throwsAssertionError,
      );
      expect(
        () => SkinMetric(kind: SkinMetricKind.oiliness, amount: -0.1),
        throwsAssertionError,
      );
    });

    test('need is how much attention the area wants, 0 to 1', () {
      expect(
        const SkinMetric(kind: SkinMetricKind.oiliness, amount: 0.7).need,
        0.7,
      );
      expect(
        const SkinMetric(kind: SkinMetricKind.hydration, amount: 0.8).need,
        closeTo(0.2, 1e-9),
      );
    });
  });

  group('SkinAnalysis', () {
    test('the score matches the Figma example (76 for its four bars)', () {
      expect(make().score, 76);
    });

    test('a perfect skin scores 100, the worst possible scores 40', () {
      expect(make(spots: 0, breakouts: 0, oil: 0, hydration: 1).score, 100);
      expect(make(spots: 1, breakouts: 1, oil: 1, hydration: 0).score, 40);
    });

    test('the score is always between 0 and 100', () {
      for (final a in [0.0, 0.5, 1.0]) {
        final score = make(spots: a, breakouts: a, oil: a, hydration: a).score;
        expect(score, inInclusiveRange(0, 100));
      }
    });

    test('focus is the two areas that need most attention, biggest first', () {
      expect(make().focus.map((m) => m.kind), [
        SkinMetricKind.darkSpots,
        SkinMetricKind.oiliness,
      ]);
    });

    test('dry skin puts hydration in the focus', () {
      final focus = make(
        spots: 0.2,
        breakouts: 0.2,
        oil: 0.2,
        hydration: 0.1,
      ).focus.map((m) => m.kind);
      expect(focus.first, SkinMetricKind.hydration);
    });

    test('equal needs keep the on-screen order', () {
      final focus = make(
        spots: 0.5,
        breakouts: 0.5,
        oil: 0.5,
        hydration: 0.5,
      ).focus.map((m) => m.kind);
      expect(focus, [SkinMetricKind.darkSpots, SkinMetricKind.breakouts]);
    });

    test(
      'tone follows the score: good from 75, fair from 50, else needs care',
      () {
        expect(
          make(spots: 0.1, breakouts: 0.1, oil: 0.1, hydration: 0.9).tone,
          SkinTone.good,
        );
        expect(make().tone, SkinTone.good); // 76
        expect(
          make(spots: 0.7, breakouts: 0.7, oil: 0.7, hydration: 0.4).tone,
          SkinTone.fair,
        );
        expect(
          make(spots: 1, breakouts: 1, oil: 1, hydration: 0).tone,
          SkinTone.needsCare,
        );
      },
    );

    test('exposes its four measures', () {
      expect(make().metrics.length, 4);
    });
  });
}
