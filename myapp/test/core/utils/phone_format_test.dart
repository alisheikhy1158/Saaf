// Covers: 02 Sign up (phone field shows "312 456 7890" as the user types)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/utils/phone_format.dart';

void main() {
  group('formatPakistanMobileInput', () {
    const cases = <String, String>{
      '': '',
      '3': '3',
      '312': '312',
      '3124': '312 4',
      '312456': '312 456',
      '3124567': '312 456 7',
      '3124567890': '312 456 7890',
      '31245678901234': '312 456 7890', // extra digits are dropped
      '0312 456 7890': '312 456 7890', // leading 0 dropped
      '+92 312 4567890': '312 456 7890', // country code dropped
      '+923124567890': '312 456 7890',
      '0092 312 4567890': '312 456 7890',
      '312-456-7890': '312 456 7890',
      'abc': '',
      '3a1b2': '312',
    };
    cases.forEach((input, expected) {
      test('"$input" → "$expected"', () {
        expect(formatPakistanMobileInput(input), expected);
      });
    });

    test('is idempotent', () {
      for (final input in cases.keys) {
        final once = formatPakistanMobileInput(input);
        expect(formatPakistanMobileInput(once), once);
      }
    });
  });
}
