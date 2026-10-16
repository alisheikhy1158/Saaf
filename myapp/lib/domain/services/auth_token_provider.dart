/// Hands out the signed-in user's current sign-in token, which our own server
/// checks before it answers (so only real users can use the AI coach).
abstract interface class AuthTokenProvider {
  /// A fresh token, or null when nobody is signed in.
  Future<String?> idToken();
}
