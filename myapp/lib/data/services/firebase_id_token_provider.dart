import 'package:saaf/data/services/firebase_bootstrap.dart';
import 'package:saaf/domain/services/auth_token_provider.dart';

/// The signed-in user's Firebase token, fetched on demand (never stored by us).
/// Null when nobody is signed in or Firebase is not set up on this build.
class FirebaseIdTokenProvider implements AuthTokenProvider {
  const FirebaseIdTokenProvider();

  @override
  Future<String?> idToken() async {
    try {
      final auth = await ensureFirebaseAuth();
      return await auth.currentUser?.getIdToken();
    } on Object {
      return null;
    }
  }
}
