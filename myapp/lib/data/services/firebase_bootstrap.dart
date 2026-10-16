import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:saaf/core/config/env.dart';

/// The iOS bundle id, which Firebase needs to match the iOS app.
const String _iosBundleId = 'com.saafapp.saaf';

/// Builds the Firebase settings for [platform] from build-time values, or null
/// when this platform is unsupported or a value is missing. Passing the values
/// in code means no google-services.json / GoogleService-Info.plist files are
/// needed in the repository.
FirebaseOptions? buildFirebaseOptions({
  required TargetPlatform platform,
  required String projectId,
  required String messagingSenderId,
  required String apiKeyAndroid,
  required String appIdAndroid,
  required String apiKeyIos,
  required String appIdIos,
}) {
  if (projectId.isEmpty || messagingSenderId.isEmpty) return null;
  switch (platform) {
    case TargetPlatform.android:
      if (apiKeyAndroid.isEmpty || appIdAndroid.isEmpty) return null;
      return FirebaseOptions(
        apiKey: apiKeyAndroid,
        appId: appIdAndroid,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      );
    case TargetPlatform.iOS:
      if (apiKeyIos.isEmpty || appIdIos.isEmpty) return null;
      return FirebaseOptions(
        apiKey: apiKeyIos,
        appId: appIdIos,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        iosBundleId: _iosBundleId,
      );
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return null;
  }
}

/// Initialises Firebase once (on first use) and returns its auth instance.
/// Throws a [StateError] when Firebase is not configured for this build.
Future<FirebaseAuth> ensureFirebaseAuth() async {
  if (Firebase.apps.isEmpty) {
    final options = buildFirebaseOptions(
      platform: defaultTargetPlatform,
      projectId: Env.firebaseProjectId,
      messagingSenderId: Env.firebaseMessagingSenderId,
      apiKeyAndroid: Env.firebaseApiKeyAndroid,
      appIdAndroid: Env.firebaseAppIdAndroid,
      apiKeyIos: Env.firebaseApiKeyIos,
      appIdIos: Env.firebaseAppIdIos,
    );
    if (options == null) {
      throw StateError(
        'Firebase is not configured for this build. See docs/firebase-setup.md.',
      );
    }
    await Firebase.initializeApp(options: options);
  }
  return FirebaseAuth.instance;
}
