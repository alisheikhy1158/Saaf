// Covers: 11 Weekly check-in — a rule-based coach (no AI, so no third-party data
// sharing): answers in, one of four outcomes out; never a diagnosis
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/domain/usecases/evaluate_check_in.dart';

CheckInAnswers answers(SkinFeel feel, BreakoutChange breakouts) =>
    CheckInAnswers(skinFeel: feel, breakouts: breakouts);

void main() {
  const evaluate = EvaluateCheckIn();

  group('outcome', () {
    test(
      'Figma example: less oily and 1–2 small breakouts in week 3 is on track',
      () {
        expect(
          evaluate(
            answers(SkinFeel.lessOily, BreakoutChange.fewSmall),
            week: 3,
          ),
          CheckInOutcome.onTrack,
        );
      },
    );

    test('no new breakouts is on track, whatever the skin feels like', () {
      for (final feel in [SkinFeel.lessOily, SkinFeel.same, SkinFeel.other]) {
        expect(
          evaluate(answers(feel, BreakoutChange.none), week: 4),
          CheckInOutcome.onTrack,
          reason: '$feel',
        );
      }
    });

    test('painful or many breakouts: see a professional', () {
      expect(
        evaluate(answers(SkinFeel.lessOily, BreakoutChange.severe), week: 3),
        CheckInOutcome.seeProfessional,
      );
    });

    test('irritated skin: see a professional', () {
      expect(
        evaluate(answers(SkinFeel.irritated, BreakoutChange.none), week: 5),
        CheckInOutcome.seeProfessional,
      );
    });

    test(
      'seeing a professional comes before everything else, even in week 1',
      () {
        expect(
          evaluate(answers(SkinFeel.irritated, BreakoutChange.severe), week: 1),
          CheckInOutcome.seeProfessional,
        );
      },
    );

    test('more breakouts than before: adjust the routine', () {
      expect(
        evaluate(answers(SkinFeel.same, BreakoutChange.more), week: 3),
        CheckInOutcome.adjust,
      );
    });

    test('drier or tighter skin: adjust the routine', () {
      expect(
        evaluate(answers(SkinFeel.drier, BreakoutChange.none), week: 3),
        CheckInOutcome.adjust,
      );
    });

    test('the first week is too early to say "on track"', () {
      expect(
        evaluate(answers(SkinFeel.lessOily, BreakoutChange.none), week: 1),
        CheckInOutcome.keepGoing,
      );
    });

    test('unclear answers mean keep going', () {
      expect(
        evaluate(answers(SkinFeel.same, BreakoutChange.other), week: 4),
        CheckInOutcome.keepGoing,
      );
      expect(
        evaluate(answers(SkinFeel.other, BreakoutChange.other), week: 4),
        CheckInOutcome.keepGoing,
      );
    });

    test('an unanswered question counts as unclear', () {
      expect(
        evaluate(const CheckInAnswers(), week: 4),
        CheckInOutcome.keepGoing,
      );
      expect(
        evaluate(
          const CheckInAnswers(breakouts: BreakoutChange.severe),
          week: 4,
        ),
        CheckInOutcome.seeProfessional,
      );
    });
  });

  group('answers', () {
    test('copyWith changes one field and keeps the rest', () {
      const a = CheckInAnswers(skinFeel: SkinFeel.same);
      final b = a.copyWith(breakouts: BreakoutChange.none);
      expect(b.skinFeel, SkinFeel.same);
      expect(b.breakouts, BreakoutChange.none);
      expect(b.note, isNull);
    });

    test('a note can be added', () {
      expect(const CheckInAnswers().copyWith(note: 'chin').note, 'chin');
    });
  });

  group('weekNumberSince', () {
    final start = DateTime(2026, 10, 1);

    test('the first week is week 1, from day 0 to day 6', () {
      expect(weekNumberSince(start, DateTime(2026, 10, 1)), 1);
      expect(weekNumberSince(start, DateTime(2026, 10, 7)), 1);
    });

    test('day 7 starts week 2, day 14 starts week 3', () {
      expect(weekNumberSince(start, DateTime(2026, 10, 8)), 2);
      expect(weekNumberSince(start, DateTime(2026, 10, 15)), 3);
    });

    test('the time of day does not matter', () {
      expect(
        weekNumberSince(DateTime(2026, 10, 1, 23), DateTime(2026, 10, 8, 1)),
        2,
      );
    });

    test('a start in the future is still week 1', () {
      expect(weekNumberSince(DateTime(2026, 11, 1), DateTime(2026, 10, 1)), 1);
    });
  });

  test('the next progress photo is 30 days after the last one', () {
    expect(
      nextProgressPhoto(DateTime(2026, 10, 15, 9, 41)),
      DateTime(2026, 11, 14),
    );
  });
}
