import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/services/firebase_bootstrap.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

/// Firebase Authentication (docs/adr/0001-backend.md): phone OTP, Google and
/// Apple. Firebase is initialised lazily on first use so the app starts fast.
///
/// Every Firebase error becomes a [Failure] (see [mapFirebaseAuthError]); nothing
/// is thrown to the UI. Tokens stay inside the Firebase SDK, which keeps them in
/// the platform's secure storage (SEC-1); this class never sees them.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({Future<FirebaseAuth> Function()? authProvider})
    : _authProvider = authProvider ?? ensureFirebaseAuth;

  static const Duration _resendDelay = Duration(seconds: 30);
  static const Duration _codeTimeout = Duration(seconds: 60);

  final Future<FirebaseAuth> Function() _authProvider;
  final _changes = StreamController<AuthSession?>.broadcast();

  String? _verificationId;
  int? _resendToken;
  String? _lastE164;
  ConfirmationResult? _webConfirmation;

  @override
  Stream<AuthSession?> get sessionChanges => _changes.stream;

  @override
  Future<Result<OtpChallenge>> requestOtp(PhoneNumber phone) async {
    const challenge = OtpChallenge(resendAfter: _resendDelay);
    try {
      final auth = await _authProvider();
      if (_lastE164 != phone.e164) _resendToken = null;
      _lastE164 = phone.e164;

      if (kIsWeb) {
        _webConfirmation = await auth.signInWithPhoneNumber(phone.e164);
        return const Ok(challenge);
      }

      final done = Completer<Result<OtpChallenge>>();
      await auth.verifyPhoneNumber(
        phoneNumber: phone.e164,
        forceResendingToken: _resendToken,
        timeout: _codeTimeout,
        verificationCompleted: (credential) async {
          // Android can verify the number by itself (instant verification or
          // SMS auto-retrieval): sign in now and tell the app.
          try {
            final user = (await auth.signInWithCredential(credential)).user;
            _announce(_sessionFrom(user));
          } on FirebaseAuthException {
            // Fall back to the user typing the code.
          }
          if (!done.isCompleted) done.complete(const Ok(challenge));
        },
        verificationFailed: (error) {
          if (!done.isCompleted) {
            done.complete(Err(mapFirebaseAuthError(error)));
          }
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!done.isCompleted) done.complete(const Ok(challenge));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
      return await done.future.timeout(
        _codeTimeout + const Duration(seconds: 5),
        onTimeout: () => const Err(NetworkFailure()),
      );
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthError(e));
    } on Object {
      return const Err(UnknownFailure('requestOtp'));
    }
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  }) async {
    try {
      final UserCredential credential;
      if (kIsWeb) {
        final confirmation = _webConfirmation;
        if (confirmation == null) {
          return const Err(UnknownFailure('no-verification'));
        }
        credential = await confirmation.confirm(code);
      } else {
        final verificationId = _verificationId;
        if (verificationId == null) {
          return const Err(UnknownFailure('no-verification'));
        }
        final auth = await _authProvider();
        credential = await auth.signInWithCredential(
          PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: code,
          ),
        );
      }
      return _finish(credential);
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthError(e));
    } on Object {
      return const Err(UnknownFailure('verifyOtp'));
    }
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle() =>
      _signInWithProvider(GoogleAuthProvider());

  @override
  Future<Result<AuthSession>> signInWithApple() =>
      _signInWithProvider(AppleAuthProvider());

  Future<Result<AuthSession>> _signInWithProvider(AuthProvider provider) async {
    try {
      final auth = await _authProvider();
      final credential = kIsWeb
          ? await auth.signInWithPopup(provider)
          : await auth.signInWithProvider(provider);
      return _finish(credential);
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthError(e));
    } on Object {
      return const Err(UnknownFailure('signInWithProvider'));
    }
  }

  Result<AuthSession> _finish(UserCredential credential) {
    final session = _sessionFrom(credential.user);
    if (session == null) return const Err(UnknownFailure('no-user'));
    _announce(session);
    return Ok(session);
  }

  @override
  Future<AuthSession?> currentSession() async =>
      _sessionFrom((await _authProvider()).currentUser);

  @override
  Future<void> signOut() async {
    final auth = await _authProvider();
    await auth.signOut();
    _verificationId = null;
    _resendToken = null;
    _webConfirmation = null;
    _announce(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final auth = await _authProvider();
      final user = auth.currentUser;
      if (user == null) return const Ok<void>(null);
      await user.delete();
      _verificationId = null;
      _resendToken = null;
      _webConfirmation = null;
      _announce(null);
      return const Ok<void>(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Err(UnknownFailure('requires-recent-login'));
      }
      return Err(mapFirebaseAuthError(e));
    } on Object {
      return const Err(UnknownFailure('deleteAccount'));
    }
  }

  void _announce(AuthSession? session) => _changes.add(session);

  static AuthSession? _sessionFrom(User? user) {
    if (user == null) return null;
    final phone = user.phoneNumber;
    final name = user.displayName?.trim();
    return AuthSession(
      userId: user.uid,
      phoneE164: phone == null || phone.isEmpty ? null : phone,
      displayName: name == null || name.isEmpty ? null : name,
    );
  }
}

/// Maps a Firebase error code to a [Failure] the UI can explain.
Failure mapFirebaseAuthError(FirebaseAuthException error) =>
    switch (error.code) {
      'network-request-failed' => const NetworkFailure(),
      'invalid-phone-number' => const ValidationFailure('phone'),
      'invalid-verification-code' => const ValidationFailure('code'),
      final code => UnknownFailure(code),
    };
