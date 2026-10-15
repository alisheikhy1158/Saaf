import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

/// Stand-in backend used in Chrome, tests and walking-skeleton builds until the
/// real one exists (docs/adr/0001-backend.md). Any valid number "receives" a
/// code and [fixedCode] always works. MUST be replaced before store release.
class FakeAuthRepository implements AuthRepository {
  static const String fixedCode = '123456';

  AuthSession? _session;

  @override
  Future<Result<OtpChallenge>> requestOtp(PhoneNumber phone) async =>
      const Ok(OtpChallenge(resendAfter: Duration(seconds: 30)));

  @override
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  }) async {
    if (code != fixedCode) return const Err(ValidationFailure('code'));
    return Ok(
      _session = AuthSession(
        userId: 'fake-${phone.e164}',
        phoneE164: phone.e164,
      ),
    );
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle() async =>
      Ok(_session = const AuthSession(userId: 'fake-google'));

  @override
  Future<Result<AuthSession>> signInWithApple() async =>
      Ok(_session = const AuthSession(userId: 'fake-apple'));

  @override
  Future<AuthSession?> currentSession() async => _session;

  @override
  Future<void> signOut() async => _session = null;
}
