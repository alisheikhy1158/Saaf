// Covers: security settings in the native config (OWASP Mobile Top 10 2024:
// M5 insecure communication, M8 security misconfiguration, M9 insecure data
// storage). These files only take effect in a Codemagic build; this test
// keeps them from being undone by accident.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();

  group('Android', () {
    test('no backups of face photos and skin answers (cloud or adb)', () {
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('android:fullBackupContent="false"'));
      // Android 12+: no cloud backup and no device-to-device copy either.
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      final rules = File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();
      expect(rules, contains('<cloud-backup>'));
      expect(rules, contains('<device-transfer>'));
      expect(
        RegExp(
          '<exclude domain="(root|file|database|sharedpref)"',
        ).allMatches(rules).length,
        8,
      );
    });

    test('only HTTPS (no plain-text traffic)', () {
      expect(manifest, contains('android:usesCleartextTraffic="false"'));
    });

    test('only the launcher screen is open to other apps', () {
      final exported = RegExp(
        'android:exported="true"',
      ).allMatches(manifest).length;
      expect(exported, 1);
    });
  });

  group('iOS', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    test('App Transport Security is not switched off', () {
      expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
    });
  });
}
