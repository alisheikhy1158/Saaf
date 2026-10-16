import 'package:flutter/material.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/utils/countdown_format.dart';
import 'package:saaf/presentation/features/auth/controllers/verify_code_controller.dart';
import 'package:saaf/presentation/features/auth/widgets/sent_to_line.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_keypad.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_otp_field.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma screen 03 — Verify code (node 2:140). Boxes + on-screen keypad as in
/// Figma; tapping the boxes also opens the system keyboard so SMS autofill and
/// paste work (design.md §9.4).
class VerifyCodeScreen extends ConsumerWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSignInProvider);
    if (pending == null) return const _BackToSignUp();

    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final form = ref.watch(verifyCodeControllerProvider);
    final controller = ref.read(verifyCodeControllerProvider.notifier);
    final secondsLeft = ref.watch(resendCountdownProvider);

    // Android can verify the number by itself; move on as soon as that happens.
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (previous == null && next != null && context.mounted) {
        context.go(SaafRoute.privacyConsent.path);
      }
    });

    void backToSignUp() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.signUp.path);

    final failure = form.failure;
    final errorText = failure == null
        ? null
        : failure is ValidationFailure
        ? l10n.verifyWrongCode
        : withDetail(l10n.verifyFailed, failure, show: Env.diagnostics);

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.verifyCode.name}'),
      topBar: SaafTopBar.back(tooltip: l10n.back, onBack: backToSignUp),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x12),
          Text(l10n.verifyTitle, style: context.text.headlineLarge),
          SizedBox(height: space.x8),
          SentToLine(phone: pending.phone.display, onEdit: backToSignUp),
          SizedBox(height: space.x28),
          SaafOtpField(
            key: const ValueKey('verify-otp'),
            value: form.code,
            onChanged: controller.setCode,
            semanticLabel: l10n.verifyCodeLabel,
            hasError: errorText != null,
          ),
          SizedBox(height: space.x16),
          if (errorText != null)
            Semantics(
              liveRegion: true,
              child: SaafMessageRow(
                icon: Icons.error_outline,
                text: errorText,
                color: context.colors.error,
              ),
            )
          else if (secondsLeft > 0)
            Row(
              spacing: space.x6,
              children: [
                Icon(
                  Icons.schedule,
                  size: tokens.size.iconChip,
                  color: tokens.textCaption,
                ),
                Flexible(
                  child: Text(
                    l10n.verifyResendIn(formatCountdown(secondsLeft)),
                    style: tokens.styles.meta.copyWith(
                      color: tokens.textCaption,
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaafButton.text(
                label: l10n.verifyResend,
                onPressed: controller.resend,
              ),
            ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SaafButton.primary(
            label: l10n.verifyButton,
            isLoading: form.isSubmitting,
            onPressed: form.canSubmit
                ? () async {
                    final signedIn = await controller.submit();
                    if (signedIn && context.mounted) {
                      context.go(SaafRoute.privacyConsent.path);
                    }
                  }
                : null,
          ),
          SizedBox(height: space.x14),
          SaafKeypad(
            enabled: !form.isSubmitting,
            onDigit: controller.addDigit,
            onDelete: controller.backspace,
            deleteLabel: l10n.keypadDelete,
          ),
        ],
      ),
    );
  }
}

/// Verify code needs a number to verify; without one (e.g. a reloaded page) go
/// back to Sign up.
class _BackToSignUp extends StatefulWidget {
  const _BackToSignUp();

  @override
  State<_BackToSignUp> createState() => _BackToSignUpState();
}

class _BackToSignUpState extends State<_BackToSignUp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(SaafRoute.signUp.path);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
