import 'dart:convert';

/// What to do for skin, given how far away the event is.
enum EventStage {
  /// More than 8 weeks: build the routine; the time for new actives.
  buildRoutine,

  /// 4–8 weeks: one last new product at most.
  lastNewProduct,

  /// 2–4 weeks: no new actives, keep the routine steady.
  noNewActives,

  /// 1–2 weeks: nothing new at all (products, facials, threading).
  nothingNew,

  /// The last week: gentle, hydrate, sleep, sunscreen.
  gentleWeek,

  /// The day itself.
  today,

  /// It has passed.
  over,
}

/// A big day the user is getting their skin ready for (a wedding, a mehndi…).
/// Kept on the phone.
class LifeEvent {
  const LifeEvent({required this.name, required this.date});

  final String name;
  final DateTime date;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  int daysLeft(DateTime now) => _day(date).difference(_day(now)).inDays;

  EventStage stageOn(DateTime now) => switch (daysLeft(now)) {
    < 0 => EventStage.over,
    0 => EventStage.today,
    <= 7 => EventStage.gentleWeek,
    <= 14 => EventStage.nothingNew,
    <= 28 => EventStage.noNewActives,
    <= 56 => EventStage.lastNewProduct,
    _ => EventStage.buildRoutine,
  };

  /// Starting a new active now risks a reaction on the day.
  bool tooCloseForNewProduct(DateTime now) {
    final left = daysLeft(now);
    return left >= 0 && left <= 28;
  }

  String encode() =>
      jsonEncode({'name': name, 'date': _day(date).toIso8601String()});

  static LifeEvent? decode(String json) {
    try {
      final data = jsonDecode(json);
      if (data case {'name': final String name, 'date': final String date}) {
        final day = DateTime.tryParse(date);
        if (day != null && name.trim().isNotEmpty) {
          return LifeEvent(name: name.trim(), date: day);
        }
      }
    } on Object {
      // Nothing usable.
    }
    return null;
  }
}
