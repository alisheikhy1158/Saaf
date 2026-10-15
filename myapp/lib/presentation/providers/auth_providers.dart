import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/fake_auth_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';
import 'package:saaf/domain/usecases/request_otp.dart';
import 'package:saaf/domain/usecases/social_sign_in.dart';
import 'package:saaf/domain/usecases/verify_otp.dart';

part 'auth_providers.g.dart';

/// The fake backend until ADR 0001 picks the real one. Must be replaced before
/// a store release (the fake accepts a fixed code).
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => FakeAuthRepository();

@riverpod
RequestOtp requestOtp(Ref ref) => RequestOtp(ref.watch(authRepositoryProvider));

@riverpod
VerifyOtp verifyOtp(Ref ref) => VerifyOtp(ref.watch(authRepositoryProvider));

@riverpod
SocialSignIn socialSignIn(Ref ref) =>
    SocialSignIn(ref.watch(authRepositoryProvider));

/// Who is signed in right now (null when nobody is). The router guard in
/// Phase 5 reads this.
@Riverpod(keepAlive: true)
class AuthSessionController extends _$AuthSessionController {
  @override
  AuthSession? build() => null;

  void set(AuthSession? session) => state = session;
}
