// Covers: Profile — the user can add their name and age (kept on the phone)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/profile_details.dart';

void main() {
  group('cleanName', () {
    test('trims and tidies spaces', () {
      expect(ProfileDetails.cleanName('  Ayesha   Khan '), 'Ayesha Khan');
    });

    test('empty or blank is not a name', () {
      expect(ProfileDetails.cleanName(''), isNull);
      expect(ProfileDetails.cleanName('   '), isNull);
    });

    test('over 40 letters is refused', () {
      expect(ProfileDetails.cleanName('a' * 40), 'a' * 40);
      expect(ProfileDetails.cleanName('a' * 41), isNull);
    });

    test('Urdu names are fine', () {
      expect(ProfileDetails.cleanName('عائشہ خان'), 'عائشہ خان');
    });
  });

  group('parseAge', () {
    test('a number between 16 and 99', () {
      expect(ProfileDetails.parseAge('16'), 16);
      expect(ProfileDetails.parseAge(' 27 '), 27);
      expect(ProfileDetails.parseAge('99'), 99);
    });

    test('too young, too old or not a number', () {
      expect(ProfileDetails.parseAge('15'), isNull);
      expect(ProfileDetails.parseAge('100'), isNull);
      expect(ProfileDetails.parseAge('abc'), isNull);
      expect(ProfileDetails.parseAge(''), isNull);
    });
  });

  group('storage text', () {
    test('age is stored as text and read back', () {
      expect(ProfileDetails.ageFromStored('27'), 27);
      expect(ProfileDetails.ageFromStored(null), isNull);
      expect(ProfileDetails.ageFromStored('x'), isNull);
    });
  });
}
