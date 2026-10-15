import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/features/onboarding/controllers/consent_form_controller.dart';
import 'package:saaf/presentation/features/onboarding/widgets/consent_agree_label.dart';
import 'package:saaf/presentation/features/onboarding/widgets/privacy_point.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_check_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma screen 04 — Privacy consent (node 2:227).
///
/// Unlike the mockup, both boxes start unticked and "Agree and continue" stays
/// disabled until both are ticked: consent must be an explicit action.
class PrivacyConsentScreen extends ConsumerWidget {
  const PrivacyConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final form = ref.watch(consentFormControllerProvider);
    final controller = ref.read(consentFormControllerProvider.notifier);

    void openTerms() => context.push(SaafRoute.terms.path);
    void openPrivacy() => context.push(SaafRoute.privacyPolicy.path);

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.privacyConsent.name}'),
      topBar: SaafTopBar.back(
        tooltip: l10n.back,
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(SaafRoute.welcome.path),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x8),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaafIconCircle(
              key: ValueKey('consent-shield'),
              icon: Icons.verified_user_outlined,
              size: SaafIconCircleSize.large,
              tone: SaafIconCircleTone.sageTint,
              iconColor: SaafIconCircleColor.sage,
            ),
          ),
          SizedBox(height: space.x20),
          Text(l10n.consentTitle, style: tokens.styles.screenTitle),
          SizedBox(height: space.titleToSubtitle),
          Text(
            l10n.consentSubtitle,
            style: context.text.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: space.sectionGapLarge),
          Column(
            spacing: space.x18,
            children: [
              PrivacyPoint(
                icon: Icons.lock_outline,
                title: l10n.consentPointDeviceTitle,
                body: l10n.consentPointDeviceBody,
              ),
              PrivacyPoint(
                icon: Icons.verified_user_outlined,
                title: l10n.consentPointNeverSoldTitle,
                body: l10n.consentPointNeverSoldBody,
              ),
              PrivacyPoint(
                icon: Icons.delete_outline,
                title: l10n.consentPointDeleteTitle,
                body: l10n.consentPointDeleteBody,
              ),
            ],
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SaafCheckRow(
            key: const ValueKey('consent-terms-row'),
            value: form.termsAccepted,
            onChanged: controller.setTermsAccepted,
            semanticLabel: l10n.consentAgree(
              l10n.termsTitle,
              l10n.privacyPolicyTitle,
            ),
            customActions: {
              l10n.openDocumentAction(l10n.termsTitle): openTerms,
              l10n.openDocumentAction(l10n.privacyPolicyTitle): openPrivacy,
            },
            label: ConsentAgreeLabel(
              onOpenTerms: openTerms,
              onOpenPrivacy: openPrivacy,
            ),
          ),
          SaafCheckRow(
            key: const ValueKey('consent-age-row'),
            value: form.ageConfirmed,
            onChanged: controller.setAgeConfirmed,
            semanticLabel: l10n.consentAge,
            label: Text(l10n.consentAge),
          ),
          SizedBox(height: space.x10),
          SaafButton.primary(
            label: l10n.consentContinue,
            isLoading: form.isSubmitting,
            onPressed: form.canSubmit
                ? () async {
                    final saved = await controller.submit();
                    if (saved && context.mounted) {
                      context.go(SaafRoute.skinQuiz.path);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
