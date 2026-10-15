import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/usecases/verify_otp.dart';
import 'package:saaf/presentation/features/auth/state/verify_code_state.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';

part 'verify_code_controller.g.dart';

@riverpod
class VerifyCodeController extends _$VerifyCodeController {
  @override
  VerifyCodeState build() => const VerifyCodeState();

  void addDigit(int digit) {
    if (state.isSubmitting || state.code.length >= VerifyOtp.codeLength) return;
    state = state.copyWith(code: '${state.code}$digit', failure: null);
  }

  void backspace() {
    if (state.isSubmitting || state.code.isEmpty) return;
    state = state.copyWith(
      code: state.code.substring(0, state.code.length - 1),
      failure: null,
    );
  }

  /// Replaces the whole code (system keyboard, SMS autofill, paste).
  void setCode(String digits) {
    if (state.isSubmitting) return;
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(
      code: clean.length > VerifyOtp.codeLength
          ? clean.substring(0, VerifyOtp.codeLength)
          : clean,
      failure: null,
    );
  }

  /// Checks the code. True when the user is signed in.
  Future<bool> submit() async {
    final pending = ref.read(pendingSignInProvider);
    if (!state.canSubmit || pending == null) return false;
    state = state.copyWith(isSubmitting: true, failure: null);
    final result = await ref.read(verifyOtpProvider)(
      phone: pending.phone,
      code: state.code,
    );
    final session = result.valueOrNull;
    if (session != null) {
      ref.read(authSessionControllerProvider.notifier).set(session);
    }
    state = state.copyWith(isSubmitting: false, failure: result.failureOrNull);
    return session != null;
  }

  /// Asks for a new code; the countdown restarts. True when it was sent.
  Future<bool> resend() async {
    final pending = ref.read(pendingSignInProvider);
    if (pending == null) return false;
    final result = await ref.read(requestOtpProvider)(pending.phone.e164);
    final sent = result.valueOrNull;
    if (sent == null) {
      state = state.copyWith(failure: result.failureOrNull);
      return false;
    }
    state = state.copyWith(code: '', failure: null);
    ref
        .read(pendingSignInProvider.notifier)
        .set(
          PendingSignIn(
            phone: sent.phone,
            resendAfter: sent.challenge.resendAfter,
          ),
        );
    return true;
  }
}

/// Seconds left before a new code may be requested. Restarts whenever a new
/// [PendingSignIn] is set (that is, whenever a code is sent).
@riverpod
class ResendCountdown extends _$ResendCountdown {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    final seconds =
        ref.watch(pendingSignInProvider)?.resendAfter.inSeconds ?? 0;
    _timer?.cancel();
    if (seconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final next = state - 1;
        state = next < 0 ? 0 : next;
        if (next <= 0) timer.cancel();
      });
    }
    return seconds;
  }
}
