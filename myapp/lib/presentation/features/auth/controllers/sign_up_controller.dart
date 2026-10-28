import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/usecases/social_sign_in.dart';
import 'package:saaf/presentation/features/auth/state/sign_up_state.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';

part 'sign_up_controller.g.dart';

@riverpod
class SignUpController extends _$SignUpController {
  @override
  SignUpState build() => const SignUpState();

  void setInput(String value) => state = state.copyWith(
    input: value,
    sendFailure: null,
    socialFailure: null,
  );

  /// Texts a code to the typed number. True when it was sent.
  Future<bool> sendCode() async {
    if (!state.canSend) return false;
    state = state.copyWith(
      isSubmitting: true,
      sendFailure: null,
      socialFailure: null,
    );
    final result = await ref.read(requestOtpProvider)(state.input);
    final sent = result.valueOrNull;
    if (sent != null) {
      ref
          .read(pendingSignInProvider.notifier)
          .set(
            PendingSignIn(
              phone: sent.phone,
              resendAfter: sent.challenge.resendAfter,
            ),
          );
    }
    state = state.copyWith(
      isSubmitting: false,
      sendFailure: result.failureOrNull,
    );
    return sent != null;
  }

  /// Signs in with Google or Apple. True when signed in.
  Future<bool> signInWith(SocialProvider provider) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(
      isSubmitting: true,
      sendFailure: null,
      socialFailure: null,
    );
    final result = await ref.read(socialSignInProvider)(provider);
    final session = result.valueOrNull;
    if (session != null) {
      ref.read(authSessionControllerProvider.notifier).set(session);
    }
    final failure = result.failureOrNull;
    state = state.copyWith(
      isSubmitting: false,
      // Closing the sign-in window is not an error.
      socialFailure: failure is SignInCancelled ? null : failure,
    );
    return session != null;
  }
}
