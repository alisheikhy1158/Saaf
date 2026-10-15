// Covers: architecture.md §1 (layers), §2 (file rules), CLAUDE.md rule 5
// (no dart:io in presentation/domain).
import 'package:flutter_test/flutter_test.dart';

import '../helpers/source_scanner.dart';
import 'no_hardcoded_values_test.dart' show dartFiles;

void main() {
  test('every file in lib respects the layer and feature import rules', () {
    final violations = <String>[];
    for (final file in dartFiles('lib')) {
      violations.addAll(
        findLayerViolations(file.path, file.readAsStringSync()),
      );
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
