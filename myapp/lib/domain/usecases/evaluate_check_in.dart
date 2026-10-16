import 'package:saaf/domain/entities/check_in.dart';

/// Turns the two check-in answers into one outcome with fixed rules (no AI, so
/// nothing is sent to a third party). Safety first: irritated skin or painful
/// breakouts always say "see a professional".
class EvaluateCheckIn {
  const EvaluateCheckIn();

  /// [week] is the week of the routine (1-based); the first week is too early
  /// to call anything "on track".
  CheckInOutcome call(CheckInAnswers answers, {required int week}) {
    final feel = answers.skinFeel;
    final breakouts = answers.breakouts;

    if (breakouts == BreakoutChange.severe || feel == SkinFeel.irritated) {
      return CheckInOutcome.seeProfessional;
    }
    if (breakouts == BreakoutChange.more || feel == SkinFeel.drier) {
      return CheckInOutcome.adjust;
    }
    if (week < 2) return CheckInOutcome.keepGoing;
    if (feel == SkinFeel.lessOily ||
        breakouts == BreakoutChange.none ||
        breakouts == BreakoutChange.fewSmall) {
      return CheckInOutcome.onTrack;
    }
    return CheckInOutcome.keepGoing;
  }
}
