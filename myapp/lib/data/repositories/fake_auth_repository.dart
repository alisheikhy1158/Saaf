import 'dart:async';

import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

/// Stand-in backend used in Chrome, tests and builds without Firebase settings
/// (see Env.useFirebase). Any valid number "receives" a code and [fixedCode]
/// always works. Never use it for a store release.
class FakeAuthRepository implements AuthRepository {
  static const String fixedCode = '123456';

  final _changes = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  Result<AuthSession> _signedIn(AuthSession session) {
    _session = session;
    _changes.add(session);
    return Ok(session);
  }

  @override
  Future<Result<OtpChallenge>> requestOtp(PhoneNumber phone) async =>
      const Ok(OtpChallenge(resendAfter: Duration(seconds: 30)));

  @override
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  }) async {
    if (code != fixedCode) return const Err(ValidationFailure('code'));
    return _signedIn(
      AuthSession(userId: 'fake-${phone.e164}', phoneE164: phone.e164),
    );
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle() async =>
      _signedIn(const AuthSession(userId: 'fake-google'));

  @override
  Future<Result<AuthSession>> signInWithApple() async =>
      _signedIn(const AuthSession(userId: 'fake-apple'));

  @override
  Future<AuthSession?> currentSession() async => _session;

  @override
  Stream<AuthSession?> get sessionChanges => _changes.stream;

  @override
  Future<void> signOut() async {
    _session = null;
    _changes.add(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    await signOut();
    return const Ok<void>(null);
  }
}
