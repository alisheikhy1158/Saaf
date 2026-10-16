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

/// Which week of something that began on [start] it is on [today]: 1 for the
/// first seven days, 2 for the next seven, and so on. Never below 1.
int weekNumberSince(DateTime start, DateTime today) {
  final days = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
  return days < 0 ? 1 : days ~/ 7 + 1;
}

/// How long after a progress photo the next one is due.
const int progressPhotoIntervalDays = 30;

/// The date the next progress photo is due after one taken on [lastPhoto].
DateTime nextProgressPhoto(DateTime lastPhoto) => DateTime(
  lastPhoto.year,
  lastPhoto.month,
  lastPhoto.day + progressPhotoIntervalDays,
);
