// Covers: docs/adr/0001-backend.md — Firebase settings come from --dart-define,
// so no config files are committed (CLAUDE.md rule 8)
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/services/firebase_bootstrap.dart';

FirebaseOptions? build(
  TargetPlatform platform, {
  String projectId = 'saaf-test',
  String sender = '123456789',
  String keyA = 'key-android',
  String idA = '1:123456789:android:abc',
  String keyI = 'key-ios',
  String idI = '1:123456789:ios:def',
}) => buildFirebaseOptions(
  platform: platform,
  projectId: projectId,
  messagingSenderId: sender,
  apiKeyAndroid: keyA,
  appIdAndroid: idA,
  apiKeyIos: keyI,
  appIdIos: idI,
);

void main() {
  test('Android gets the Android key and app id', () {
    final options = build(TargetPlatform.android)!;
    expect(options.apiKey, 'key-android');
    expect(options.appId, '1:123456789:android:abc');
    expect(options.projectId, 'saaf-test');
    expect(options.messagingSenderId, '123456789');
  });

  test('iOS gets the iOS key, app id and the bundle id', () {
    final options = build(TargetPlatform.iOS)!;
    expect(options.apiKey, 'key-ios');
    expect(options.appId, '1:123456789:ios:def');
    expect(options.iosBundleId, 'com.saafapp.saaf');
  });

  test(
    'a missing value means "not configured" (null), not a half-built config',
    () {
      expect(build(TargetPlatform.android, keyA: ''), isNull);
      expect(build(TargetPlatform.android, idA: ''), isNull);
      expect(build(TargetPlatform.iOS, keyI: ''), isNull);
      expect(build(TargetPlatform.iOS, idI: ''), isNull);
      expect(build(TargetPlatform.android, projectId: ''), isNull);
      expect(build(TargetPlatform.iOS, sender: ''), isNull);
    },
  );

  test('the Android values are not needed on iOS and vice versa', () {
    expect(build(TargetPlatform.iOS, keyA: '', idA: ''), isNotNull);
    expect(build(TargetPlatform.android, keyI: '', idI: ''), isNotNull);
  });

  test('desktop platforms are unsupported', () {
    for (final p in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ]) {
      expect(build(p), isNull, reason: '$p');
    }
  });
}
