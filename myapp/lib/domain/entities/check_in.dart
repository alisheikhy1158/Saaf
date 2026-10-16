/// How the skin felt this week (first question of the weekly check-in).
/// [other] is a typed reply the coach does not interpret.
enum SkinFeel { lessOily, same, drier, irritated, other }

/// New breakouts since last week (second question). [other] is a typed reply.
enum BreakoutChange { none, fewSmall, more, severe, other }

/// What the coach concludes. Guidance only, never a diagnosis.
enum CheckInOutcome {
  /// "Likely on track."
  onTrack,

  /// Nothing clear yet: carry on.
  keepGoing,

  /// Something to change in the routine (more moisture, ease off).
  adjust,

  /// Worth asking a dermatologist or pharmacist.
  seeProfessional,
}

/// What the user said in one weekly check-in.
class CheckInAnswers {
  const CheckInAnswers({this.skinFeel, this.breakouts, this.note});

  final SkinFeel? skinFeel;
  final BreakoutChange? breakouts;

  /// Free text the user typed; kept with the check-in, never analysed.
  final String? note;

  CheckInAnswers copyWith({
    SkinFeel? skinFeel,
    BreakoutChange? breakouts,
    String? note,
  }) => CheckInAnswers(
    skinFeel: skinFeel ?? this.skinFeel,
    breakouts: breakouts ?? this.breakouts,
    note: note ?? this.note,
  );
}

/// A finished weekly check-in, kept on the phone.
class CheckIn {
  const CheckIn({
    required this.date,
    required this.week,
    required this.answers,
    required this.outcome,
  });

  final DateTime date;

  /// Which week of the routine this was (1-based).
  final int week;
  final CheckInAnswers answers;
  final CheckInOutcome outcome;
}
