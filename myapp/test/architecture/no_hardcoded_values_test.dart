// Covers: design.md §1 rule T-1 (no hardcoded colours / text styles / spacing),
// hex codes only in lib/core/theme/tokens.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/source_scanner.dart';

Iterable<File> dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where(
      (f) =>
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.freezed.dart'),
    );

void main() {
  test('lib/presentation has no hardcoded colours, text sizes or spacing', () {
    final violations = <String>[];
    for (final file in dartFiles('lib/presentation')) {
      for (final v in findHardcodedValues(file.readAsStringSync())) {
        violations.add('${file.path}: $v');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('hex colour codes exist only in lib/core/theme/tokens.dart', () {
    final violations = <String>[];
    for (final file in dartFiles('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.endsWith('lib/core/theme/tokens.dart')) continue;
      for (final hex in findHexColours(file.readAsStringSync())) {
        violations.add('$path: $hex');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
