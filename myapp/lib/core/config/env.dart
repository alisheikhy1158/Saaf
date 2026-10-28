/// Build-time settings, passed with `--dart-define` (set in Codemagic's
/// "app_config" group; nothing here is a secret and nothing is committed).
/// Firebase values are in Firebase console → Project settings → Your apps.
abstract final class Env {
  /// Use the real Firebase backend. Without it the app uses the fake backend
  /// (fixed code 123456) — fine for Chrome and tests, never for a store release.
  static const bool useFirebase = bool.fromEnvironment('USE_FIREBASE');

  /// Demo camera, gallery and permission (no real device needed). For trying the
  /// scan screens in Chrome without a webcam: `--dart-define=FAKE_CAMERA=true`.
  static const bool fakeCamera = bool.fromEnvironment('FAKE_CAMERA');

  /// Pretend store: "buying" Saaf Pro is free. For Chrome demos only; debug
  /// builds use it too. `--dart-define=FAKE_PURCHASES=true`.
  static const bool fakePurchases = bool.fromEnvironment('FAKE_PURCHASES');

  /// RevenueCat's public SDK keys (Codemagic `app_config`, already passed by
  /// the store workflows). With one set, Saaf Pro is sold through Google Play /
  /// the App Store.
  static const String revenueCatAndroidKey = String.fromEnvironment(
    'RC_GOOGLE_API_KEY',
  );
  static const String revenueCatIosKey = String.fromEnvironment(
    'RC_APPLE_API_KEY',
  );

  /// Address of our AI proxy (a small server in front of the AI model; it holds
  /// the secret key, the app never does). Empty on builds without it.
  /// `--dart-define=AI_PROXY_URL=https://saaf-ai.<you>.workers.dev`
  static const String aiProxyUrl = String.fromEnvironment('AI_PROXY_URL');

  /// Shows a technical detail line under sign-in errors, to find out what went
  /// wrong on a real phone. For the TEST app only: `--dart-define=DIAGNOSTICS=true`.
  static const bool diagnostics = bool.fromEnvironment('DIAGNOSTICS');

  /// TEST APP ONLY: phone sign-in works with Firebase TEST numbers without the
  /// app check (see FirebaseAuthRepository.testPhoneNumbersOnly).
  /// `--dart-define=PHONE_TEST_MODE=true`. Never in a store build.
  static const bool phoneTestMode = bool.fromEnvironment('PHONE_TEST_MODE');

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseApiKeyAndroid = String.fromEnvironment(
    'FIREBASE_API_KEY_ANDROID',
  );
  static const String firebaseAppIdAndroid = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
  );
  static const String firebaseApiKeyIos = String.fromEnvironment(
    'FIREBASE_API_KEY_IOS',
  );
  static const String firebaseAppIdIos = String.fromEnvironment(
    'FIREBASE_APP_ID_IOS',
  );
}
