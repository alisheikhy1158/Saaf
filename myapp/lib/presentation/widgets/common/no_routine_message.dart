import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';

/// Home and Routine before there is a routine: says what is missing (the
/// quiz, an analysed face scan, Saaf AI) or that Saaf AI is still looking, and
/// gives the one way forward. The app never fills the routine with products
/// nobody checked for this user.
class NoRoutineMessage extends ConsumerWidget {
  const NoRoutineMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(skinProfileControllerProvider);
    final analysis = ref.watch(skinAnalysisProvider);
    final consent = ref.watch(aiConsentStateProvider);
    final plan = ref.watch(aiRoutinePlanControllerProvider);

    if (profile.skinType == null && profile.concerns.isEmpty) {
      return SaafStatusMessage(
        icon: Icons.spa_outlined,
        title: l10n.routineEmptyTitle,
        body: l10n.routineEmptyBody,
        actionLabel: l10n.routineEmptyAction,
        onAction: () => context.go(SaafRoute.skinQuiz.path),
      );
    }
    if (analysis.isLoading || plan.isLoading) {
      return SaafStatusMessage.waiting(
        icon: Icons.auto_awesome,
        title: l10n.routineWaitingTitle,
        body: analysis.isLoading ? null : l10n.aiPicksLoading,
      );
    }
    if (analysis.value == null) {
      return SaafStatusMessage(
        icon: Icons.face_retouching_natural,
        title: l10n.routineNoScanTitle,
        body: l10n.routineNoScanBody,
        actionLabel: l10n.routineNoScanAction,
        onAction: () => context.push(SaafRoute.selfieCapture.path),
      );
    }
    // Saaf AI answered, but none of its options suit the safety answers.
    if (plan.value != null) return _noneSuit(context, l10n);
    if (plan.hasError) {
      final failure = plan.error;
      return SaafStatusMessage(
        icon: Icons.error_outline,
        title: l10n.routinePlanFailedTitle,
        body: failure is Failure
            ? withDetail(
                l10n.routinePlanFailedBody,
                failure,
                show: Env.diagnostics,
              )
            : l10n.routinePlanFailedBody,
        actionLabel: l10n.scanTryAgain,
        onAction: () =>
            ref.read(aiRoutinePlanControllerProvider.notifier).retry(),
      );
    }
    if (consent != true) {
      return SaafStatusMessage(
        icon: Icons.auto_awesome,
        title: l10n.routineNoScanTitle,
        body: l10n.routineNoAiBody,
        actionLabel: l10n.aiPicksTurnOn,
        onAction: () => context.push(SaafRoute.aiConsentAndReturn),
      );
    }
    return _noneSuit(context, l10n);
  }

  static Widget _noneSuit(BuildContext context, AppLocalizations l10n) =>
      SaafStatusMessage(
        icon: Icons.spa_outlined,
        title: l10n.routineEmptyTitle,
        body: l10n.routineNoneSuitBody,
        actionLabel: l10n.routineEmptyAction,
        onAction: () => context.go(SaafRoute.skinQuiz.path),
      );
}
