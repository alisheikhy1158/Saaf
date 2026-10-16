// Covers: 14 Profile — Reminders row ("8:00 · 22:30")
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';

void main() {
  group('ReminderTime', () {
    test('prints hours without a leading zero and minutes with one', () {
      expect(const ReminderTime(8, 0).text, '8:00');
      expect(const ReminderTime(22, 30).text, '22:30');
      expect(const ReminderTime(0, 5).text, '0:05');
    });

    test('equal times are equal', () {
      expect(const ReminderTime(8, 0), const ReminderTime(8, 0));
      expect(const ReminderTime(8, 0), isNot(const ReminderTime(8, 1)));
    });

    test('rejects a time that does not exist', () {
      expect(() => ReminderTime(24, 0), throwsAssertionError);
      expect(() => ReminderTime(8, 60), throwsAssertionError);
      expect(() => ReminderTime(-1, 0), throwsAssertionError);
    });
  });

  group('ReminderSettings', () {
    test('starts at the Figma times, both on', () {
      const settings = ReminderSettings();
      expect(settings.summary('Off'), '8:00 · 22:30');
    });

    test('only the reminders that are on are listed', () {
      expect(const ReminderSettings(nightOn: false).summary('Off'), '8:00');
      expect(const ReminderSettings(morningOn: false).summary('Off'), '22:30');
    });

    test('with both off it says Off', () {
      expect(
        const ReminderSettings(morningOn: false, nightOn: false).summary('Off'),
        'Off',
      );
    });

    test('copyWith changes one thing and keeps the rest', () {
      final changed = const ReminderSettings().copyWith(
        morning: const ReminderTime(7, 15),
      );
      expect(changed.morning, const ReminderTime(7, 15));
      expect(changed.night, const ReminderTime(22, 30));
      expect(changed.morningOn, isTrue);
    });
  });

  group('storage text', () {
    test('round trips every field', () {
      const settings = ReminderSettings(
        morning: ReminderTime(7, 15),
        night: ReminderTime(23, 5),
        morningOn: false,
      );
      final back = ReminderSettings.decode(settings.encode());
      expect(back.morning, const ReminderTime(7, 15));
      expect(back.night, const ReminderTime(23, 5));
      expect(back.morningOn, isFalse);
      expect(back.nightOn, isTrue);
    });

    test('nothing stored, or text that makes no sense, gives the defaults', () {
      for (final bad in [
        null,
        '',
        'x',
        '1,2,3',
        '8,0,1,22,30',
        'a,b,c,d,e,f',
        '25,0,1,22,30,1',
        '8,61,1,22,30,1',
      ]) {
        expect(
          ReminderSettings.decode(bad).summary('Off'),
          '8:00 · 22:30',
          reason: '$bad',
        );
      }
    });
  });
}
