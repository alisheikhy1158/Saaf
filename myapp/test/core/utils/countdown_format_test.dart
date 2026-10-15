// Covers: 03 Verify code ("Resend code in 0:24")
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/countdown_format.dart';

void main() {
  const cases = <int, String>{
    0: '0:00',
    1: '0:01',
    9: '0:09',
    24: '0:24',
    30: '0:30',
    59: '0:59',
    60: '1:00',
    65: '1:05',
    600: '10:00',
  };
  cases.forEach((seconds, expected) {
    test('$seconds s → $expected', () {
      expect(formatCountdown(seconds), expected);
    });
  });

  test('negative values show 0:00', () {
    expect(formatCountdown(-3), '0:00');
  });
}
