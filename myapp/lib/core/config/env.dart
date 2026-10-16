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
