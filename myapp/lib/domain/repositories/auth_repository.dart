import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';

/// Sign-in with the backend chosen in ADR 0001. Until then a fake implements it.
abstract interface class AuthRepository {
  Future<Result<OtpChallenge>> requestOtp(PhoneNumber phone);

  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  });

  Future<Result<AuthSession>> signInWithGoogle();

  /// Required on iOS whenever another third-party sign-in is offered (Apple 4.8).
  Future<Result<AuthSession>> signInWithApple();

  Future<AuthSession?> currentSession();

  /// Emits whenever the signed-in user changes without the app asking: Android
  /// can verify a number automatically, and signing out emits null.
  Stream<AuthSession?> get sessionChanges;

  /// Ends the session and wipes tokens (SEC-7).
  Future<void> signOut();
}
