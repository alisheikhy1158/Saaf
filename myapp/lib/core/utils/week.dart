/// [date] with the time cut off (local midnight).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// The seven days of the week that contains [day], Monday first (the Home week
/// strip). Built from calendar fields, so a daylight-saving change cannot skip
/// or repeat a day.
List<DateTime> weekOf(DateTime day) {
  final monday = day.day - (day.weekday - DateTime.monday);
  return [
    for (var i = 0; i < 7; i++) DateTime(day.year, day.month, monday + i),
  ];
}
