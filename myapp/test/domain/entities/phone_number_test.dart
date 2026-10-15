// Covers: SEC-8 (validate phone at the boundary), test-strategy §3 (+92 phone
// validation is table-driven). Pakistani mobiles: +92 3XX XXXXXXX.
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/phone_number.dart';

void main() {
  group('accepts a Pakistani mobile number written any common way', () {
    const valid = <String, String>{
      '312 456 7890': '3124567890',
      '3124567890': '3124567890',
      '0312 4567890': '3124567890',
      '03124567890': '3124567890',
      '+92 312 456 7890': '3124567890',
      '+923124567890': '3124567890',
      '0092 312 4567890': '3124567890',
      '92 312 456 7890': '3124567890',
      '(312) 456-7890': '3124567890',
      '  312 456 7890  ': '3124567890',
      '300 0000000': '3000000000',
      '345 9999999': '3459999999',
    };
    valid.forEach((input, national) {
      test('"$input"', () {
        final result = PhoneNumber.parse(input);
        expect(result.isOk, isTrue);
        expect(result.valueOrNull?.nationalNumber, national);
      });
    });
  });

  group('rejects everything else with a ValidationFailure("phone")', () {
    const invalid = <String>[
      '',
      '   ',
      '312',
      '312 456 789', // one digit short
      '312 456 78901', // one digit too many
      '212 456 7890', // landline range, mobiles start with 3
      '012 456 7890',
      '+1 312 456 7890',
      '312 abc 7890',
      'not a number',
      '312-456-78#0',
      '+92',
    ];
    for (final input in invalid) {
      test('"$input"', () {
        expect(
          PhoneNumber.parse(input).failureOrNull,
          const ValidationFailure('phone'),
        );
      });
    }
  });

  group('formatting', () {
    final phone = PhoneNumber.parse('0312 4567890').valueOrNull!;

    test('e164 is +92 followed by the ten digits', () {
      expect(phone.e164, '+923124567890');
    });

    test('display groups 3-3-4 like the Figma screens', () {
      expect(phone.display, '+92 312 456 7890');
    });
  });

  test('numbers written differently are equal', () {
    expect(
      PhoneNumber.parse('0312 4567890').valueOrNull,
      PhoneNumber.parse('+92 312 456 7890').valueOrNull,
    );
    expect(
      PhoneNumber.parse('312 456 7890').valueOrNull,
      isNot(PhoneNumber.parse('312 456 7891').valueOrNull),
    );
  });
}
