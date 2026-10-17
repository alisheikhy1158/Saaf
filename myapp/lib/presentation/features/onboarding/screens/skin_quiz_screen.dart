import 'package:flutter/material.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/quiz_step.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/onboarding/controllers/skin_quiz_controller.dart';
import 'package:saaf/presentation/features/onboarding/quiz/quiz_step_views.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Skin quiz, one question per screen (Figma 05, node 2:305, is step 2 of 5; the
/// other four steps follow the same layout). [step] is 1-based and clamped.
///
/// With [edit] it is ONE step opened from Profile: no progress, no Skip, a Save
/// button, and Save (or Back) returns to where the user came from.
class SkinQuizScreen extends ConsumerWidget {
  const SkinQuizScreen({super.key, this.step = 1, this.edit = false});

  final int step;
  final bool edit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizStep = QuizStep.fromNumber(step);
    final view = quizStepViews[quizStep]!;
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final quiz = ref.watch(skinQuizControllerProvider(quizStep));
    final controller = ref.read(skinQuizControllerProvider(quizStep).notifier);

    void toNextScreen() {
      final next = quizStep.next;
      if (edit) {
        context.canPop() ? context.pop() : context.go(SaafRoute.profile.path);
      } else if (next == null) {
        ref.read(quizDoneProvider.notifier).markDone();
        // The products they use now, then the face scan.
        context.go('${SaafRoute.myProducts.path}?setup=1');
      } else {
        context.push('${SaafRoute.skinQuiz.path}/${next.number}');
      }
    }

    return SaafScaffold(
      key: ValueKey(
        quizStep.number == 1
            ? 'screen-${SaafRoute.skinQuiz.name}'
            : 'screen-${SaafRoute.skinQuiz.name}-${quizStep.number}',
      ),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(
          tooltip: l10n.back,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(SaafRoute.privacyConsent.path),
        ),
        center: edit
            ? null
            : Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: space.x16),
                child: SaafProgressBar(value: quizStep.number / QuizStep.count),
              ),
        trailing: edit
            ? null
            : TextButton(
                onPressed: toNextScreen,
                style: TextButton.styleFrom(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: space.x8,
                  ),
                  textStyle: tokens.styles.skip,
                ),
                child: Text(l10n.quizSkip),
              ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: space.x16),
          if (!edit) ...[
            SaafOverline(
              l10n.quizStepLabel(quizStep.number, QuizStep.count),
              strong: true,
            ),
            SizedBox(height: space.x8),
          ],
          Text(view.title(l10n), style: context.text.headlineSmall),
          SizedBox(height: space.x6),
          Text(
            view.hint(l10n),
            style: context.text.bodyMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          SizedBox(height: space.sectionGapSmall),
          Column(
            spacing: space.optionGap,
            children: [
              for (final option in view.options)
                SaafOptionTile(
                  icon: option.icon,
                  title: option.title(l10n),
                  caption: option.caption(l10n),
                  selected: quiz.selected.contains(option.value),
                  onTap: () => controller.toggle(option.value),
                ),
              if (quizStep == QuizStep.skinType)
                SaafButton.text(
                  key: const ValueKey('quiz-tissue-test'),
                  label: l10n.quizTissueEntry,
                  leadingIcon: Icons.science_outlined,
                  onPressed: () async {
                    final type = await context.push<SkinType>(
                      SaafRoute.skinTypeTest.path,
                    );
                    if (type != null) controller.toggle(type);
                  },
                ),
            ],
          ),
        ],
      ),
      bottom: SaafButton.primary(
        key: const ValueKey('quiz-next'),
        label: edit ? l10n.commonSave : l10n.quizNext,
        trailingIcon: edit ? null : Icons.arrow_forward,
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
