// Covers: architecture.md §2 (directory structure), §4.6 (strict analysis)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const requiredDirs = <String>[
    'lib/core/config',
    'lib/core/error',
    'lib/core/l10n',
    'lib/core/platform',
    'lib/core/router',
    'lib/core/theme',
    'lib/core/utils',
    'lib/domain/entities',
    'lib/domain/repositories',
    'lib/domain/services',
    'lib/domain/usecases',
    'lib/data/local',
    'lib/data/remote',
    'lib/data/repositories',
    'lib/data/services/web',
    'lib/data/sync',
    'lib/presentation/providers',
    'lib/presentation/widgets/common',
    'lib/presentation/features/onboarding',
    'lib/presentation/features/auth',
    'lib/presentation/features/scan',
    'lib/presentation/features/routine',
    'lib/presentation/features/home',
    'lib/presentation/features/products',
    'lib/presentation/features/coach',
    'lib/presentation/features/progress',
    'lib/presentation/features/paywall',
    'lib/presentation/features/profile',
  ];

  group('folder skeleton', () {
    for (final dir in requiredDirs) {
      test('$dir exists', () {
        expect(Directory(dir).existsSync(), isTrue);
      });
    }

    test('main.dart only wires ProviderScope + SaafApp', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('ProviderScope'));
      expect(main, contains('SaafApp'));
      expect(File('lib/app.dart').existsSync(), isTrue);
    });
  });

  group('analysis_options.yaml', () {
    final options = File('analysis_options.yaml').readAsStringSync();

    for (final mode in [
      'strict-casts',
      'strict-inference',
      'strict-raw-types',
    ]) {
      test('enables $mode', () {
        expect(RegExp('$mode:\\s*true').hasMatch(options), isTrue);
      });
    }

    for (final lint in [
      'prefer_const_constructors',
      'avoid_print',
      'always_declare_return_types',
      'require_trailing_commas',
      'unawaited_futures',
      // The layer scanner (test/helpers/source_scanner.dart) only sees
      // package: imports, so relative imports inside lib/ are banned.
      'always_use_package_imports',
    ]) {
      test('enables lint $lint', () {
        expect(RegExp('$lint:\\s*true').hasMatch(options), isTrue);
      });
    }

    test('excludes generated files from analysis', () {
      expect(options, contains('**/*.g.dart'));
      expect(options, contains('**/*.freezed.dart'));
    });
  });
}
