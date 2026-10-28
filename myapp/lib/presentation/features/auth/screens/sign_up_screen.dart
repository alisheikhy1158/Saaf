import 'package:flutter/material.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/usecases/social_sign_in.dart';
import 'package:saaf/presentation/features/auth/controllers/sign_up_controller.dart';
import 'package:saaf/presentation/widgets/common/linked_sentence.dart';
import 'package:saaf/presentation/widgets/common/phone_number_input_formatter.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_labeled_divider.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_text_field.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma screen 02 — Sign up (node 2:76). Phone number + code, or Google; on iOS
/// also "Continue with Apple" (required when another third-party sign-in is
/// offered, design.md §9.3).
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final form = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);
    Future<void> socialSignIn(SocialProvider provider) async {
      final signedIn = await controller.signInWith(provider);
      if (signedIn && context.mounted) {
        // Someone who already agreed on this phone goes straight home (the
        // guard still sends them to the quiz if it is not done).
        context.go(
          ref.read(consentStatusProvider) == true
              ? SaafRoute.home.path
              : SaafRoute.privacyConsent.path,
        );
      }
    }

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.signUp.name}'),
      topBar: SaafTopBar.back(
        tooltip: l10n.back,
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(SaafRoute.welcome.path),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x12),
          Text(l10n.signUpTitle, style: context.text.headlineLarge),
          SizedBox(height: space.titleToSubtitle),
          Text(
            l10n.signUpSubtitle,
            style: context.text.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: space.x28),
          SaafTextField(
            label: l10n.phoneLabel,
            prefixText: PhoneNumber.dialCode,
            hintText: l10n.phoneHint,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [PhoneNumberInputFormatter()],
            isValid: form.isValid,
            helperText: l10n.phoneHelper,
            helperIcon: Icons.info_outline,
            errorText: form.sendFailure == null
                ? null
                : withDetail(
                    l10n.signUpSendFailed,
                    form.sendFailure!,
                    show: Env.diagnostics,
                  ),
            onChanged: controller.setInput,
          ),
          SizedBox(height: space.sectionGapLarge),
          SaafButton.primary(
            label: l10n.sendCode,
            isLoading: form.isSubmitting,
            onPressed: form.canSend
                ? () async {
                    final sent = await controller.sendCode();
                    if (sent && context.mounted) {
                      await context.push(SaafRoute.verifyCode.path);
                    }
                  }
                : null,
          ),
          SizedBox(height: space.sectionGapSmall),
          SaafLabeledDivider(label: l10n.orDivider),
          SizedBox(height: space.sectionGapSmall),
          Column(
            spacing: space.x12,
            children: [
              // Apple on both: required on iOS next to Google (App Store
              // 4.8), and Firebase signs in with Apple on Android in a browser.
              SaafButton.outline(
                label: l10n.continueWithApple,
                leadingIcon: Icons.apple,
                onPressed: form.isSubmitting
                    ? null
                    : () => socialSignIn(SocialProvider.apple),
              ),
              SaafButton.outline(
                label: l10n.continueWithGoogle,
                // Plain "G" as in Figma; the official Google logo asset replaces
                // it when real Google sign-in is wired (branding guidelines).
                leading: Text('G', style: context.text.titleMedium),
                onPressed: form.isSubmitting
                    ? null
                    : () => socialSignIn(SocialProvider.google),
              ),
              if (form.socialFailure != null)
                Semantics(
                  liveRegion: true,
                  child: SaafMessageRow(
                    icon: Icons.error_outline,
                    text: withDetail(
                      l10n.socialSignInFailed,
                      form.socialFailure!,
                      show: Env.diagnostics,
                    ),
                    color: context.colors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
      bottom: LinkedSentence(
        sentence: l10n.signUpLegal,
        style: tokens.styles.legal,
        textAlign: TextAlign.center,
        onOpenTerms: () => context.push(SaafRoute.terms.path),
        onOpenPrivacy: () => context.push(SaafRoute.privacyPolicy.path),
      ),
    );
  }
}
