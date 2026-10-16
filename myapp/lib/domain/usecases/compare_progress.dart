import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';

enum ChangeDirection { better, worse, same }

/// Overall picture, in words the screen can use.
enum ProgressTrend { improving, steady, slipping }

/// How one measure moved between two scans.
class Change {
  const Change({
    required this.kind,
    required this.percent,
    required this.direction,
  });

  final SkinMetricKind kind;

  /// Signed whole percent of the earlier value: −18 means "18 % lower". 0 when
  /// the earlier value was 0.
  final int percent;
  final ChangeDirection direction;

  /// How far it moved, whichever way.
  int get size => percent.abs();
}

/// What changed between two scans.
class Progress {
  const Progress({required this.from, required this.to, required this.changes});

  final DateTime from;
  final DateTime to;

  /// Every measure, in screen order.
  final List<Change> changes;

  /// The two measures that moved most. Ties keep the on-screen order.
  List<Change> get biggest {
    final indexed = changes.indexed.toList()
      ..sort((a, b) {
        final bySize = b.$2.size.compareTo(a.$2.size);
        return bySize != 0 ? bySize : a.$1.compareTo(b.$1);
      });
    return [for (final (_, change) in indexed.take(2)) change];
  }

  /// Changes smaller than this are noise.
  static const int _noticeable = 5;

  int _signed(Change c) => switch (c.direction) {
    ChangeDirection.better => c.size,
    ChangeDirection.worse => -c.size,
    ChangeDirection.same => 0,
  };

  /// The measure that improved most, if any improved by a noticeable amount.
  Change? get mostImproved {
    final better =
        changes
            .where(
              (c) =>
                  c.direction == ChangeDirection.better &&
                  c.size >= _noticeable,
            )
            .toList()
          ..sort((a, b) => b.size.compareTo(a.size));
    return better.isEmpty ? null : better.first;
  }

  ProgressTrend get trend {
    final net = changes.fold(0, (sum, c) => sum + _signed(c));
    final anyGain = mostImproved != null;
    final anySlip = changes.any(
      (c) => c.direction == ChangeDirection.worse && c.size >= _noticeable,
    );
    if (anyGain && net >= 0) return ProgressTrend.improving;
    if (anySlip && net < 0) return ProgressTrend.slipping;
    return ProgressTrend.steady;
  }
}

/// Compares two analyses of the same user.
class CompareProgress {
  const CompareProgress();

  Progress call({required SkinAnalysis before, required SkinAnalysis after}) {
    final changes = <Change>[
      for (final b in before.metrics)
        _change(
          b,
          after.metrics.where((a) => a.kind == b.kind).firstOrNull ?? b,
        ),
    ];
    return Progress(from: before.takenAt, to: after.takenAt, changes: changes);
  }

  Change _change(SkinMetric before, SkinMetric after) {
    final percent = before.amount == 0
        ? 0
        : ((after.amount - before.amount) / before.amount * 100).round();
    final up = percent > 0;
    final direction = percent == 0
        ? ChangeDirection.same
        : (up == before.kind.higherIsBetter
              ? ChangeDirection.better
              : ChangeDirection.worse);
    return Change(kind: before.kind, percent: percent, direction: direction);
  }
}

/// How often a new face scan is due, in days (every two weeks).
const int scanEveryDays = 14;

/// Which week of using Saaf a comparison is: two weeks apart is week 2, four
/// weeks is week 4. Never below 1.
int weekNumber(DateTime first, DateTime latest) {
  final days = DateTime.utc(
    latest.year,
    latest.month,
    latest.day,
  ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
  final week = days ~/ 7;
  return week < 1 ? 1 : week;
}

/// Whole days left until the next scan is due, counted from the day of the
/// [latest] scan; 0 when it is due today or overdue.
int daysUntilNextScan(DateTime latest, DateTime now) {
  final passed = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime.utc(latest.year, latest.month, latest.day)).inDays;
  final left = scanEveryDays - (passed < 0 ? 0 : passed);
  return left < 0 ? 0 : left;
}
