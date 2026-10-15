import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/features/onboarding/widgets/welcome_hero.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_segmented_control.dart';

/// Figma screen 01 — Welcome (node 2:15).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _english = Locale('en');
  static const _urdu = Locale('ur');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    void openSignUp() => context.go(SaafRoute.signUp.path);

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.welcome.name}'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x8),
          const WelcomeHero(),
          SizedBox(height: space.x28),
          Text(l10n.welcomeTitle, style: context.text.displaySmall),
          SizedBox(height: space.x12),
          Text(
            l10n.welcomeSubtitle,
            style: context.text.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: space.sectionGapSmall),
          SaafSegmentedControl(
            semanticLabel: l10n.language,
            selectedIndex: isUrdu ? 1 : 0,
            segments: [
              SaafSegment(label: l10n.languageEnglish, icon: Icons.language),
              SaafSegment(label: l10n.languageUrdu),
            ],
            onChanged: (index) => ref
                .read(localeControllerProvider.notifier)
                .setLocale(index == 1 ? _urdu : _english),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: space.x6,
        children: [
          SaafButton.primary(
            label: l10n.getStarted,
            trailingIcon: Icons.arrow_forward,
            onPressed: openSignUp,
          ),
          SaafButton.text(
            label: l10n.alreadyHaveAccount,
            expand: true,
            onPressed: openSignUp,
          ),
        ],
      ),
    );
  }
}
