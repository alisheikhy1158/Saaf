// Covers: design.md §1 (rule T-1), architecture.md §2 (layer rules).
// Proves the scanners really catch violations (a guard that never fires is
// worthless), using sample source strings.
import 'package:flutter_test/flutter_test.dart';

import 'source_scanner.dart';

void main() {
  group('findHardcodedValues', () {
    test('flags Color(0x…) literals', () {
      expect(findHardcodedValues('final c = Color(0xFF123456);'), isNotEmpty);
    });

    test('flags Colors.* except Colors.transparent', () {
      expect(findHardcodedValues('x = Colors.red;'), isNotEmpty);
      expect(findHardcodedValues('x = Colors.white;'), isNotEmpty);
      expect(findHardcodedValues('x = Colors.transparent;'), isEmpty);
    });

    test('flags TextStyle with a literal fontSize', () {
      expect(findHardcodedValues('const TextStyle(fontSize: 14)'), isNotEmpty);
      expect(
        findHardcodedValues('TextStyle(\n  color: c,\n  fontSize: 12.5,\n)'),
        isNotEmpty,
      );
      expect(findHardcodedValues('TextStyle(color: c)'), isEmpty);
    });

    test('flags numeric literals in EdgeInsets / SizedBox / BorderRadius', () {
      expect(findHardcodedValues('EdgeInsets.all(16)'), isNotEmpty);
      expect(
        findHardcodedValues('EdgeInsetsDirectional.symmetric(horizontal: 20)'),
        isNotEmpty,
      );
      expect(findHardcodedValues('SizedBox(height: 8)'), isNotEmpty);
      expect(findHardcodedValues('BorderRadius.circular(12)'), isNotEmpty);
      expect(findHardcodedValues('Radius.circular(0.5)'), isNotEmpty);
    });

    test('flags literal spacing / runSpacing', () {
      expect(
        findHardcodedValues('Column(spacing: 8, children: [])'),
        isNotEmpty,
      );
      expect(findHardcodedValues('Wrap(runSpacing: 12.5)'), isNotEmpty);
      expect(
        findHardcodedValues('Row(spacing: context.saaf.space.x8)'),
        isEmpty,
      );
    });

    test('accepts token-based values', () {
      expect(
        findHardcodedValues(
          'EdgeInsetsDirectional.symmetric(horizontal: context.saaf.space.x16)',
        ),
        isEmpty,
      );
      expect(
        findHardcodedValues('SizedBox(height: context.saaf.space.x20)'),
        isEmpty,
      );
      expect(findHardcodedValues('EdgeInsets.zero'), isEmpty);
      expect(findHardcodedValues('const SizedBox.shrink()'), isEmpty);
      expect(
        findHardcodedValues('BorderRadius.circular(context.saaf.radius.r28)'),
        isEmpty,
      );
    });

    test('ignores comments', () {
      expect(
        findHardcodedValues('// Colors.red and Color(0xFF000000)'),
        isEmpty,
      );
    });
  });

  group('findHexColours', () {
    test('flags 8-digit hex literals', () {
      expect(findHexColours('const x = 0xFFAABBCC;'), isNotEmpty);
      expect(findHexColours('const x = 42;'), isEmpty);
    });
  });

  group('findLayerViolations', () {
    test('domain must stay pure Dart', () {
      const path = 'lib/domain/entities/scan.dart';
      expect(
        findLayerViolations(path, "import 'package:flutter/material.dart';"),
        isNotEmpty,
      );
      expect(findLayerViolations(path, "import 'dart:io';"), isNotEmpty);
      expect(
        findLayerViolations(path, "import 'package:saaf/data/local/db.dart';"),
        isNotEmpty,
      );
      expect(
        findLayerViolations(
          path,
          "import 'package:saaf/presentation/widgets/common/a.dart';",
        ),
        isNotEmpty,
      );
      expect(
        findLayerViolations(
          path,
          "import 'package:permission_handler/permission_handler.dart';",
        ),
        isNotEmpty,
      );
      expect(
        findLayerViolations(
          path,
          "import 'package:saaf/core/error/failure.dart';",
        ),
        isEmpty,
      );
    });

    test('presentation must not use dart:io', () {
      expect(
        findLayerViolations(
          'lib/presentation/features/home/screens/home_screen.dart',
          "import 'dart:io';",
        ),
        isNotEmpty,
      );
    });

    test('only presentation/providers may import data/', () {
      const imp = "import 'package:saaf/data/repositories/scan_repo.dart';";
      expect(
        findLayerViolations(
          'lib/presentation/features/scan/controllers/c.dart',
          imp,
        ),
        isNotEmpty,
      );
      expect(
        findLayerViolations('lib/presentation/providers/wiring.dart', imp),
        isEmpty,
      );
    });

    test('data must not import presentation', () {
      expect(
        findLayerViolations(
          'lib/data/repositories/x.dart',
          "import 'package:saaf/presentation/providers/p.dart';",
        ),
        isNotEmpty,
      );
    });

    test('a feature must not import another feature', () {
      const path = 'lib/presentation/features/home/screens/home_screen.dart';
      expect(
        findLayerViolations(
          path,
          "import 'package:saaf/presentation/features/scan/screens/s.dart';",
        ),
        isNotEmpty,
      );
      expect(
        findLayerViolations(
          path,
          "import 'package:saaf/presentation/features/home/widgets/w.dart';",
        ),
        isEmpty,
      );
      expect(
        findLayerViolations(
          path,
          "import 'package:saaf/presentation/widgets/common/saaf_button.dart';",
        ),
        isEmpty,
      );
    });
  });
}
