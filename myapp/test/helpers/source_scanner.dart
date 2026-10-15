// Source scanners behind the architecture tests (design.md §1, architecture.md §2).
// Pure string functions so they can be unit-tested with sample code.

String _stripComments(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'//[^\n]*'), '');

/// A numeric literal that is not part of an identifier (so `x16` is fine).
final RegExp _numberLiteral = RegExp(r'(?<![\w.])\d+(\.\d+)?');

/// Violations of rule T-1: hardcoded colours, text sizes and spacing.
List<String> findHardcodedValues(String source) {
  final code = _stripComments(source);
  final violations = <String>[];

  if (RegExp(r'\bColor\(\s*0x').hasMatch(code)) {
    violations.add('Color(0x…) literal');
  }
  for (final m in RegExp(r'\bColors\.(\w+)').allMatches(code)) {
    if (m.group(1) != 'transparent') {
      violations.add('Colors.${m.group(1)}');
    }
  }
  if (RegExp(
    r'\bTextStyle\([^;]*?fontSize\s*:\s*\d',
    dotAll: true,
  ).hasMatch(code)) {
    violations.add('TextStyle with literal fontSize');
  }
  for (final pattern in [
    r'\bEdgeInsets(?:Directional)?\.\w+\(([^)]*)\)',
    r'\bSizedBox\(([^)]*)\)',
    r'\bBorderRadius\.circular\(([^)]*)\)',
    r'\bRadius\.circular\(([^)]*)\)',
  ]) {
    for (final m in RegExp(pattern).allMatches(code)) {
      if (_numberLiteral.hasMatch(m.group(1)!)) {
        violations.add('numeric literal in ${m.group(0)}');
      }
    }
  }
  return violations;
}

/// Hex colour literals (8 hex digits). Allowed only in `core/theme/tokens.dart`.
List<String> findHexColours(String source) => RegExp(
  r'\b0x[0-9A-Fa-f]{8}\b',
).allMatches(_stripComments(source)).map((m) => m.group(0)!).toList();

/// Layer-rule violations for the file at [path] (relative, any slash style).
List<String> findLayerViolations(String path, String source) {
  final file = path.replaceAll(r'\', '/');
  final imports = RegExp(
    r'''import\s+['"]([^'"]+)['"]''',
  ).allMatches(_stripComments(source)).map((m) => m.group(1)!).toList();

  final violations = <String>[];
  void forbid(String reason, bool Function(String) test) {
    for (final i in imports.where(test)) {
      violations.add('$file imports $i — $reason');
    }
  }

  if (file.startsWith('lib/domain/')) {
    forbid(
      'domain is pure Dart',
      (i) =>
          i.startsWith('package:flutter') ||
          i == 'dart:io' ||
          i == 'dart:ui' ||
          i.startsWith('package:drift') ||
          i.startsWith('package:permission_handler') ||
          i.startsWith('package:flutter_secure_storage') ||
          i.startsWith('package:saaf/data/') ||
          i.startsWith('package:saaf/presentation/'),
    );
  }

  if (file.startsWith('lib/presentation/')) {
    forbid('dart:io crashes on web', (i) => i == 'dart:io');
    if (!file.startsWith('lib/presentation/providers/')) {
      forbid(
        'only presentation/providers wires data/',
        (i) => i.startsWith('package:saaf/data/'),
      );
    }
  }

  if (file.startsWith('lib/data/')) {
    forbid(
      'data must not depend on presentation',
      (i) => i.startsWith('package:saaf/presentation/'),
    );
  }

  final feature = RegExp(
    r'^lib/presentation/features/([^/]+)/',
  ).firstMatch(file);
  if (feature != null) {
    final own = feature.group(1);
    forbid('a feature must not import another feature', (i) {
      final other = RegExp(
        r'^package:saaf/presentation/features/([^/]+)/',
      ).firstMatch(i);
      return other != null && other.group(1) != own;
    });
  }
  return violations;
}
