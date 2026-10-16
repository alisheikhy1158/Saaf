import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/repositories/fake_auth_repository.dart';
import 'package:saaf/data/repositories/firebase_auth_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';
import 'package:saaf/domain/usecases/request_otp.dart';
import 'package:saaf/domain/usecases/social_sign_in.dart';
import 'package:saaf/domain/usecases/verify_otp.dart';

part 'auth_providers.g.dart';

/// Firebase when the build has Firebase settings (Env.useFirebase) and runs on
/// a phone; otherwise the fake backend (Chrome, tests, local development).
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => Env.useFirebase && !kIsWeb
    ? FirebaseAuthRepository()
    : FakeAuthRepository();

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

/// Keeps [AuthSessionController] in step with changes the repository reports on
/// its own (Android automatic verification, sign-out). Watched by the app root.
@Riverpod(keepAlive: true)
void authSessionSync(Ref ref) {
  final subscription = ref
      .watch(authRepositoryProvider)
      .sessionChanges
      .listen(
        (session) =>
            ref.read(authSessionControllerProvider.notifier).set(session),
      );
  ref.onDispose(subscription.cancel);
}
