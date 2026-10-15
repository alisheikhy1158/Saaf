import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/presentation/features/onboarding/controllers/skin_quiz_controller.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma screen 05 — Skin quiz, "What bothers you most?" (node 2:305).
///
/// Only this question is designed so far; the rest of the "of 5" steps are
/// still to come, so the step numbers below are fixed to Figma's 2 of 5.
class SkinQuizScreen extends ConsumerWidget {
  const SkinQuizScreen({super.key});

  static const int _step = 2;
  static const int _totalSteps = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final quiz = ref.watch(skinQuizControllerProvider);
    final controller = ref.read(skinQuizControllerProvider.notifier);

    void toNextScreen() => context.go(SaafRoute.selfieCapture.path);

    final options = <(SkinConcern, IconData, String, String)>[
      (
        SkinConcern.darkSpots,
        Icons.auto_awesome_outlined,
        l10n.concernDarkSpotsTitle,
        l10n.concernDarkSpotsCaption,
      ),
      (
        SkinConcern.acne,
        Icons.adjust,
        l10n.concernAcneTitle,
        l10n.concernAcneCaption,
      ),
      (
        SkinConcern.oiliness,
        Icons.water_drop_outlined,
        l10n.concernOilinessTitle,
        l10n.concernOilinessCaption,
      ),
      (
        SkinConcern.dryness,
        Icons.wb_sunny_outlined,
        l10n.concernDrynessTitle,
        l10n.concernDrynessCaption,
      ),
      (
        SkinConcern.unevenTone,
        Icons.layers_outlined,
        l10n.concernUnevenToneTitle,
        l10n.concernUnevenToneCaption,
      ),
    ];

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.skinQuiz.name}'),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(
          tooltip: l10n.back,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(SaafRoute.privacyConsent.path),
        ),
        center: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.x16),
          child: const SaafProgressBar(value: _step / _totalSteps),
        ),
        trailing: TextButton(
          onPressed: toNextScreen,
          style: TextButton.styleFrom(
            padding: EdgeInsetsDirectional.symmetric(horizontal: space.x8),
            textStyle: tokens.styles.skip,
          ),
          child: Text(l10n.quizSkip),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x16),
          SaafOverline(l10n.quizStepLabel(_step, _totalSteps), strong: true),
          SizedBox(height: space.x8),
          Text(l10n.quizConcernsTitle, style: context.text.headlineSmall),
          SizedBox(height: space.x6),
          Text(
            l10n.quizConcernsHint,
            style: context.text.bodyMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: space.sectionGapSmall),
          Column(
            spacing: space.optionGap,
            children: [
              for (final (concern, icon, title, caption) in options)
                SaafOptionTile(
                  icon: icon,
                  title: title,
                  caption: caption,
                  selected: quiz.selected.contains(concern),
                  onTap: () => controller.toggle(concern),
                ),
            ],
          ),
        ],
      ),
      bottom: SaafButton.primary(
        label: l10n.quizNext,
        trailingIcon: Icons.arrow_forward,
        isLoading: quiz.isSubmitting,
        onPressed: quiz.canSubmit
            ? () async {
                final saved = await controller.submit();
                if (saved && context.mounted) toNextScreen();
              }
            : null,
      ),
    );
  }
}
