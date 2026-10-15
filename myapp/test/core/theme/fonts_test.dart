// Covers: design.md §3 (Nunito 400/700/800 + bundled Noto Naskh for Urdu),
// architecture.md OFF-5 (fonts bundled, nothing downloaded at runtime).
// google/fonts only ships these families as variable fonts (one file holding
// every weight), so each file is declared once per weight we use.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/theme/tokens.dart';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  const files = <String>[
    'assets/fonts/Nunito-Variable.ttf',
    'assets/fonts/NotoNaskhArabic-Variable.ttf',
  ];

  for (final path in files) {
    test('$path exists, is a TrueType font and is declared in pubspec', () {
      final file = File(path);
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(100000));
      // TrueType magic number 0x00010000 (not an HTML error page).
      expect(bytes.sublist(0, 4), [0x00, 0x01, 0x00, 0x00]);
      expect(pubspec, contains('asset: $path'));
    });
  }

  test('the theme families are declared with weights 400, 700 and 800', () {
    expect(pubspec, contains('family: ${SaafType.fontFamily}'));
    for (final family in SaafType.fallbackFamilies) {
      expect(pubspec, contains('family: $family'));
    }
    for (final weight in ['400', '700', '800']) {
      expect(
        pubspec,
        contains('weight: $weight'),
        reason: 'weight $weight declared',
      );
    }
  });

  for (final licence in ['OFL-Nunito.txt', 'OFL-NotoNaskhArabic.txt']) {
    test('$licence ships with the fonts (SIL Open Font Licence)', () {
      final file = File('assets/fonts/$licence');
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('SIL OPEN FONT LICENSE'));
    });
  }
}
