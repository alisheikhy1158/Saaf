/// A time of day for a reminder (24-hour clock).
class ReminderTime {
  const ReminderTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour must be 0–23'),
      assert(minute >= 0 && minute < 60, 'minute must be 0–59');

  final int hour;
  final int minute;

  /// "8:00", "22:30".
  String get text => '$hour:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

/// When the user wants to be reminded of the morning and the night routine.
/// Only the choice is stored for now; scheduling the notifications comes with
/// the notification permission flow (PLAN Phase 7).
class ReminderSettings {
  const ReminderSettings({
    this.morning = const ReminderTime(8, 0),
    this.night = const ReminderTime(22, 30),
    this.morningOn = true,
    this.nightOn = true,
  });

  final ReminderTime morning;
  final ReminderTime night;
  final bool morningOn;
  final bool nightOn;

  /// "8:00 · 22:30", with only the ones that are on; [off] when neither is.
  String summary(String off) {
    final times = [if (morningOn) morning.text, if (nightOn) night.text];
    return times.isEmpty ? off : times.join(' · ');
  }

  ReminderSettings copyWith({
    ReminderTime? morning,
    ReminderTime? night,
    bool? morningOn,
    bool? nightOn,
  }) => ReminderSettings(
    morning: morning ?? this.morning,
    night: night ?? this.night,
    morningOn: morningOn ?? this.morningOn,
    nightOn: nightOn ?? this.nightOn,
  );
}
