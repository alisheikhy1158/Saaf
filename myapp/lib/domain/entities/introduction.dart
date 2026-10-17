import 'dart:convert';

/// Where the user is in bringing a new product in slowly.
enum IntroStage {
  /// Days 1–2: a little behind the ear or on the jaw, twice a day.
  patchTest,

  /// Weeks 1–2: two nights a week.
  twiceAWeek,

  /// Weeks 3–4: every other night.
  everyOtherNight,

  /// After a mild reaction: two days off, then carry on.
  paused,

  /// After a strong reaction: stop using it.
  stopped,

  /// Fully in the routine (or nothing being introduced).
  done,
}

enum Reaction { none, mild, strong }

/// One new product being introduced slowly, with the user's daily answers to
/// "any reaction today?". One at a time; kept on the phone.
class Introduction {
  const Introduction({
    required this.productName,
    required this.startedOn,
    this.reactions = const {},
  });

  final String productName;

  /// Null when nothing is being introduced.
  final DateTime? startedOn;

  /// Answers by day (midnight).
  final Map<DateTime, Reaction> reactions;

  static const int patchDays = 2;
  static const int twiceAWeekUntilDay = 16;
  static const int everyOtherNightUntilDay = 30;
  static const int pauseDays = 2;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  IntroStage stageOn(DateTime when) {
    final start = startedOn;
    if (start == null) return IntroStage.done;
    final today = _day(when);
    final days = today.difference(_day(start)).inDays;
    if (days < 0) return IntroStage.patchTest;

    for (final MapEntry(key: day, value: reaction) in reactions.entries) {
      if (day.isAfter(today)) continue;
      if (reaction == Reaction.strong) return IntroStage.stopped;
      if (reaction == Reaction.mild &&
          today.difference(day).inDays < pauseDays) {
        return IntroStage.paused;
      }
    }

    if (days < patchDays) return IntroStage.patchTest;
    if (days < twiceAWeekUntilDay) return IntroStage.twiceAWeek;
    if (days < everyOtherNightUntilDay) return IntroStage.everyOtherNight;
    return IntroStage.done;
  }

  /// Whether to ask "any reaction today?".
  bool needsCheckIn(DateTime when) {
    final stage = stageOn(when);
    if (stage == IntroStage.done || stage == IntroStage.stopped) return false;
    return !reactions.containsKey(_day(when));
  }

  Introduction withReaction(DateTime when, Reaction reaction) => Introduction(
    productName: productName,
    startedOn: startedOn,
    reactions: {...reactions, _day(when): reaction},
  );

  String encode() => jsonEncode({
    'product': productName,
    'started': startedOn?.toIso8601String(),
    'reactions': {
      for (final e in reactions.entries) e.key.toIso8601String(): e.value.name,
    },
  });

  static Introduction? decode(String json) {
    try {
      final data = jsonDecode(json);
      if (data case {
        'product': final String product,
        'started': final String started,
      }) {
        final start = DateTime.tryParse(started);
        if (start == null) return null;
        return Introduction(
          productName: product,
          startedOn: start,
          reactions: {
            if (data['reactions'] case final Map<String, Object?> map)
              for (final e in map.entries)
                if ((
                      DateTime.tryParse(e.key),
                      Reaction.values.asNameMap()[e.value],
                    )
                    case (final day?, final reaction?))
                  _day(day): reaction,
          },
        );
      }
    } on Object {
      // Nothing usable.
    }
    return null;
  }
}
