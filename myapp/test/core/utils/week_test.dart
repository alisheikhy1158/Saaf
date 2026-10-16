// Covers: 09 Home week strip (Monday to Sunday, dates without time)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/week.dart';

void main() {
  group('dateOnly', () {
    test('drops the time', () {
      expect(
        dateOnly(DateTime(2026, 10, 15, 9, 41, 30)),
        DateTime(2026, 10, 15),
      );
    });
  });

  group('sameDay', () {
    test('ignores the time', () {
      expect(
        sameDay(DateTime(2026, 10, 15, 1), DateTime(2026, 10, 15, 23, 59)),
        isTrue,
      );
      expect(sameDay(DateTime(2026, 10, 15), DateTime(2026, 10, 16)), isFalse);
    });
  });

  group('weekOf', () {
    test(
      'Thursday 15 Oct 2026 is in the week 12–18 Oct (Monday to Sunday)',
      () {
        final days = weekOf(DateTime(2026, 10, 15, 9, 41));
        expect(days.map((d) => d.day), [12, 13, 14, 15, 16, 17, 18]);
        expect(days.first.weekday, DateTime.monday);
        expect(days.last.weekday, DateTime.sunday);
      },
    );

    test('a Monday starts its own week', () {
      expect(weekOf(DateTime(2026, 10, 12)).first, DateTime(2026, 10, 12));
    });

    test('a Sunday ends its week', () {
      expect(weekOf(DateTime(2026, 10, 18)).last, DateTime(2026, 10, 18));
      expect(weekOf(DateTime(2026, 10, 18)).first, DateTime(2026, 10, 12));
    });

    test('works across a month and year boundary', () {
      final days = weekOf(DateTime(2026, 12, 31)); // a Thursday
      expect(days.first, DateTime(2026, 12, 28));
      expect(days.last, DateTime(2027, 1, 3));
    });

    test('every day is a date without a time', () {
      expect(
        weekOf(DateTime(2026, 3, 29, 15)).every((d) => d == dateOnly(d)),
        isTrue,
      );
    });

    test('has seven days even when the clock changes', () {
      // Local-time arithmetic must not skip or repeat a day around DST.
      final days = weekOf(DateTime(2026, 3, 29));
      expect(days.length, 7);
      expect(days.map((d) => d.day).toSet().length, 7);
    });
  });
}
