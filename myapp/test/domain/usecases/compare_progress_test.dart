// Covers: 12 Monthly progress — change between two scans, the two biggest
// changes, and the overall trend (cosmetic guidance, never a diagnosis)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';

SkinAnalysis analysis(
  double spots,
  double breakouts,
  double oil,
  double hydration, {
  DateTime? date,
}) => SkinAnalysis(
  scanId: 's',
  takenAt: date ?? DateTime(2026, 10, 14),
  metrics: [
    SkinMetric(kind: SkinMetricKind.darkSpots, amount: spots),
    SkinMetric(kind: SkinMetricKind.breakouts, amount: breakouts),
    SkinMetric(kind: SkinMetricKind.oiliness, amount: oil),
    SkinMetric(kind: SkinMetricKind.hydration, amount: hydration),
  ],
);

void main() {
  const compare = CompareProgress();

  group('change per measure', () {
    test('the percentage is relative to the earlier scan', () {
      final progress = compare(
        before: analysis(0.50, 0.40, 0.50, 0.50),
        after: analysis(0.41, 0.40, 0.50, 0.53),
      );
      final spots = progress.changes.firstWhere(
        (c) => c.kind == SkinMetricKind.darkSpots,
      );
      expect(spots.percent, -18);
      final hydration = progress.changes.firstWhere(
        (c) => c.kind == SkinMetricKind.hydration,
      );
      expect(hydration.percent, 6);
    });

    test(
      'less of a problem is an improvement, more hydration is an improvement',
      () {
        final progress = compare(
          before: analysis(0.5, 0.5, 0.5, 0.5),
          after: analysis(0.4, 0.6, 0.5, 0.6),
        );
        Change of(SkinMetricKind k) =>
            progress.changes.firstWhere((c) => c.kind == k);
        expect(of(SkinMetricKind.darkSpots).direction, ChangeDirection.better);
        expect(of(SkinMetricKind.breakouts).direction, ChangeDirection.worse);
        expect(of(SkinMetricKind.oiliness).direction, ChangeDirection.same);
        expect(of(SkinMetricKind.hydration).direction, ChangeDirection.better);
      },
    );

    test('less hydration is worse', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.6),
        after: analysis(0.5, 0.5, 0.5, 0.3),
      );
      expect(
        progress.changes
            .firstWhere((c) => c.kind == SkinMetricKind.hydration)
            .direction,
        ChangeDirection.worse,
      );
    });

    test('a measure that starts at zero has no percentage change', () {
      final progress = compare(
        before: analysis(0, 0.5, 0.5, 0.5),
        after: analysis(0.3, 0.5, 0.5, 0.5),
      );
      expect(
        progress.changes
            .firstWhere((c) => c.kind == SkinMetricKind.darkSpots)
            .percent,
        0,
      );
    });

    test('keeps both dates', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5, date: DateTime(2026, 9, 14)),
        after: analysis(0.5, 0.5, 0.5, 0.5, date: DateTime(2026, 10, 14)),
      );
      expect(progress.from, DateTime(2026, 9, 14));
      expect(progress.to, DateTime(2026, 10, 14));
    });
  });

  group('biggest changes', () {
    test('the two largest by size, whichever way they went', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.41, 0.50, 0.55, 0.53),
      );
      expect(progress.biggest.map((c) => c.kind), [
        SkinMetricKind.darkSpots, // −18 %
        SkinMetricKind.oiliness, // +10 %
      ]);
    });

    test('ties keep the on-screen order', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.5, 0.5, 0.5, 0.5),
      );
      expect(progress.biggest.map((c) => c.kind), [
        SkinMetricKind.darkSpots,
        SkinMetricKind.breakouts,
      ]);
    });
  });

  group('trend', () {
    test('a clear improvement is "improving", naming the best one', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.41, 0.5, 0.5, 0.5),
      );
      expect(progress.trend, ProgressTrend.improving);
      expect(progress.mostImproved?.kind, SkinMetricKind.darkSpots);
    });

    test('small changes are "steady"', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.49, 0.51, 0.5, 0.5),
      );
      expect(progress.trend, ProgressTrend.steady);
      expect(progress.mostImproved, isNull);
    });

    test('a clear slip with no offsetting gain is "slipping"', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.6, 0.5, 0.5, 0.5),
      );
      expect(progress.trend, ProgressTrend.slipping);
    });

    test('a gain that outweighs a slip is "improving"', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.30, 0.55, 0.5, 0.5),
      );
      expect(progress.trend, ProgressTrend.improving);
    });

    test('identical scans are steady', () {
      final progress = compare(
        before: analysis(0.5, 0.5, 0.5, 0.5),
        after: analysis(0.5, 0.5, 0.5, 0.5),
      );
      expect(progress.trend, ProgressTrend.steady);
    });
  });

  // Scans are taken every two weeks (changed from monthly after the first
  // phone test), so progress is counted in weeks.
  group('week number', () {
    test('two weeks apart is week 2, four weeks is week 4', () {
      expect(weekNumber(DateTime(2026, 10, 1), DateTime(2026, 10, 15)), 2);
      expect(weekNumber(DateTime(2026, 10, 1), DateTime(2026, 10, 29)), 4);
    });

    test('a few days after the first scan is still week 1', () {
      expect(weekNumber(DateTime(2026, 10, 1), DateTime(2026, 10, 4)), 1);
      expect(weekNumber(DateTime(2026, 10, 1), DateTime(2026, 10, 1)), 1);
    });

    test('never below week 1, even if the dates are the wrong way round', () {
      expect(weekNumber(DateTime(2026, 10, 14), DateTime(2026, 10, 1)), 1);
    });
  });

  group('next scan', () {
    final latest = DateTime(2026, 10, 1, 9);

    test('is due two weeks after the last one', () {
      expect(daysUntilNextScan(latest, DateTime(2026, 10, 1, 20)), 14);
      expect(daysUntilNextScan(latest, DateTime(2026, 10, 10, 8)), 5);
      expect(daysUntilNextScan(latest, DateTime(2026, 10, 14, 23)), 1);
    });

    test('0 means it is due today or overdue, never negative', () {
      expect(daysUntilNextScan(latest, DateTime(2026, 10, 15, 8)), 0);
      expect(daysUntilNextScan(latest, DateTime(2026, 11, 20)), 0);
    });

    test('a scan "from the future" is not due yet', () {
      expect(daysUntilNextScan(latest, DateTime(2026, 9, 20)), 14);
    });
  });
}
