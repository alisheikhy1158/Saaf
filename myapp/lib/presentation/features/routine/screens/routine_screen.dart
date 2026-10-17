import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/utils/price_search.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/presentation/features/home/widgets/life_cards.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/life_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_ai_text.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_disclaimer.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_routine_step_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_segmented_control.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 08 Routine: morning and night steps with products and prices, the
/// time it takes and when to expect results. Also the loading, empty (no
/// products) and error states.
class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  RoutineTime _time = RoutineTime.morning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(routineProvider);
    final routine = async.value;
    final hasSteps =
        routine != null &&
        (routine.morning.isNotEmpty || routine.night.isNotEmpty);

    void back() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.routine.name}'),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: back),
        trailing: SaafIconButton(
          icon: Icons.notifications_none,
          tooltip: l10n.routineReminders,
          // Reminders are set up in the profile (14).
          onPressed: () => context.push(SaafRoute.profile.path),
        ),
      ),
      body: async.hasError && !async.hasValue
          ? SaafStatusMessage(
              icon: Icons.error_outline,
              title: l10n.routineErrorTitle,
              actionLabel: l10n.routineErrorAction,
              onAction: () => ref.invalidate(routineProvider),
            )
          : async.isLoading && !async.hasValue
          ? Padding(
              padding: EdgeInsetsDirectional.only(top: context.saaf.space.x36),
              child: const Center(child: CircularProgressIndicator()),
            )
          : !hasSteps
          ? SaafStatusMessage(
              icon: Icons.spa_outlined,
              title: l10n.routineEmptyTitle,
              body: l10n.routineEmptyBody,
              actionLabel: l10n.routineEmptyAction,
              onAction: () => context.go(SaafRoute.skinQuiz.path),
            )
          : _Content(
              routine: routine,
              time: _time,
              onTime: (time) => setState(() => _time = time),
            ),
      bottom: hasSteps
          ? SaafButton.primary(
              label: l10n.routineStart,
              onPressed: () => context.go(SaafRoute.home.path),
            )
          : null,
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.routine,
    required this.time,
    required this.onTime,
  });

  final Routine routine;
  final RoutineTime time;
  final ValueChanged<RoutineTime> onTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();
    final scan = ref.watch(completedScanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.routineTitle, style: tokens.styles.screenTitle),
        ),
        SizedBox(height: space.x6),
        Text(
          _subtitle(l10n, locale),
          style: context.text.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        SizedBox(height: space.x18),
        SaafSegmentedControl(
          segments: [
            SaafSegment(
              label: routineTimeName(
                l10n,
                RoutineTime.morning,
                ramadan: ref.watch(ramadanModeProvider).value == true,
              ),
              icon: Icons.wb_sunny_outlined,
            ),
            SaafSegment(
              label: routineTimeName(
                l10n,
                RoutineTime.night,
                ramadan: ref.watch(ramadanModeProvider).value == true,
              ),
              icon: Icons.nightlight_outlined,
            ),
          ],
          selectedIndex: time.index,
          onChanged: (i) => onTime(RoutineTime.values[i]),
          semanticLabel: l10n.routineTabsLabel,
          tone: SaafSegmentTone.ink,
          iconOnEvery: true,
        ),
        SizedBox(height: space.x16),
        _RoutineList(routine: routine, time: time),
        SizedBox(height: space.x14),
        if (!routine.fitsBudget) ...[
          SaafMessageRow(
            icon: Icons.info_outline,
            text: l10n.routineOverBudget,
            color: context.colors.onSurface,
          ),
          SizedBox(height: space.x8),
        ],
        SaafDisclaimer(l10n.routinePriceNote),
        SizedBox(height: space.x14),
        _ResultsInfo(
          body: scan == null
              ? l10n.routineResultsBodyNoDate
              : l10n.routineResultsBody(
                  DateFormat(
                    'd MMM',
                    locale,
                  ).format(scan.takenAt.add(const Duration(days: 30))),
                ),
        ),
        SizedBox(height: space.x14),
        _AiPicksCard(routine: routine),
      ],
    );
  }

  /// "For dark spots & breakouts · Budget Rs 6,000/month"
  String _subtitle(AppLocalizations l10n, String locale) {
    final names = [
      for (final concern in routine.concerns.take(2))
        _concernName(l10n, concern),
    ];
    final forText = switch (names) {
      [] => l10n.routineForGeneral,
      [final one] => l10n.routineFor(one),
      _ => l10n.routineFor(l10n.routineAnd(names[0], names[1])),
    };

    final band = routine.budget;
    if (band == null) return forText;
    final limit = band.maxMonthlyPkr;
    final budgetText = limit == null
        ? l10n.routineBudgetNoLimit
        : l10n.routineBudget(_rs(l10n, locale, limit));
    return l10n.routineSubtitle(forText, budgetText);
  }

  static String _concernName(AppLocalizations l10n, SkinConcern concern) =>
      switch (concern) {
        SkinConcern.darkSpots => l10n.concernDarkSpots,
        SkinConcern.acne => l10n.concernAcne,
        SkinConcern.oiliness => l10n.concernOiliness,
        SkinConcern.dryness => l10n.concernDryness,
        SkinConcern.unevenTone => l10n.concernUnevenTone,
      };
}

/// "Rs 1,450".
String _rs(AppLocalizations l10n, String locale, int amount) =>
    l10n.priceRs(NumberFormat.decimalPattern(locale).format(amount));

/// The list card: a summary line with the total, then one row per step.
class _RoutineList extends StatelessWidget {
  const _RoutineList({required this.routine, required this.time});

  final Routine routine;
  final RoutineTime time;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();
    final steps = routine.stepsFor(time);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radius.r22),
        border: Border.all(
          color: tokens.borderCard,
          width: tokens.size.borderThin,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: space.x14,
          bottom: space.x4,
          start: space.groupPaddingH,
          end: space.groupPaddingH,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: space.x6),
              child: Row(
                spacing: space.x8,
                children: [
                  Expanded(
                    child: Text(
                      l10n.routineSummary(
                        steps.length,
                        routine.minutesFor(time),
                      ),
                      style: tokens.styles.meta.copyWith(
                        color: tokens.textCaption,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        l10n.routineTotal(
                          _rs(l10n, locale, routine.totalFor(time)),
                        ),
                        style: tokens.styles.fieldLabel.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final (i, step) in steps.indexed)
              _StepRow(step: step, isLast: i == steps.length - 1),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final RoutineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();
    final category = switch (step.category) {
      ProductCategory.cleanser => l10n.stepCleanser,
      ProductCategory.treatment => l10n.stepTreatment,
      ProductCategory.moisturiser => l10n.stepMoisturiser,
      ProductCategory.sunscreen => l10n.stepSunscreen,
    };

    return SaafRoutineStepRow(
      name: step.product.name,
      caption: l10n.routineStepLine(step.number, category),
      isLast: isLast,
      // Shrinks a little at very large text sizes instead of overflowing.
      trailing: Flexible(
        flex: 2,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            // The user's own product, or one from the web (no price).
            OwnedProduct.isOwned(step.product)
                ? l10n.routineYours
                : step.product.pricePkr == 0
                ? l10n.productCheckPrice
                : _rs(l10n, locale, step.product.pricePkr),
            style: tokens.styles.segment,
          ),
        ),
      ),
    );
  }
}

class _ResultsInfo extends StatelessWidget {
  const _ResultsInfo({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.x16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.benefitGap,
          children: [
            const SaafIconCircle(icon: Icons.schedule),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.space.x2,
                children: [
                  Text(
                    l10n.routineResultsTitle,
                    style: tokens.styles.listTitle,
                  ),
                  Text(body, style: tokens.styles.pointCaption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saaf AI and the routine: an offer to turn it on, its progress, the products
/// it found on the web (marked as AI, with reasons, what people say, sources
/// and a report button, as Google Play's AI policy asks), its verdicts on the
/// products the user uses now, or a note that the app's own picks are shown.
class _AiPicksCard extends ConsumerStatefulWidget {
  const _AiPicksCard({required this.routine});

  final Routine routine;

  @override
  ConsumerState<_AiPicksCard> createState() => _AiPicksCardState();
}

enum _ReportReason { harmful, wrong, offensive, other }

class _AiPicksCardState extends ConsumerState<_AiPicksCard> {
  bool _open = false;
  bool _reported = false;

  Future<void> _report(AiRoutinePlan plan) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showModalBottomSheet<_ReportReason>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.all(context.saaf.space.x16),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.aiReportTitle,
                  style: context.text.titleMedium,
                ),
              ),
            ),
            for (final (reason, label) in [
              (_ReportReason.harmful, l10n.aiReportHarmful),
              (_ReportReason.wrong, l10n.aiReportWrong),
              (_ReportReason.offensive, l10n.aiReportOffensive),
              (_ReportReason.other, l10n.aiReportOther),
            ])
              ListTile(
                title: Text(label),
                onTap: () => Navigator.of(context).pop(reason),
              ),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;
    final text = [
      plan.summary,
      for (final pick in plan.picks) '${pick.product.name}: ${pick.why}',
      for (final review in plan.current)
        '${review.name}: ${review.verdict.name}. ${review.why}',
    ].join('\n');
    final result = await ref
        .read(aiCoachServiceProvider)
        .report(
          reply: AiMessage(
            id: 'routine-${DateTime.now().millisecondsSinceEpoch}',
            role: AiRole.assistant,
            text: text,
            createdAt: DateTime.now(),
          ),
          reason: reason.name,
        );
    if (!mounted) return;
    if (result.isOk) setState(() => _reported = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isOk ? l10n.aiReportThanks : l10n.aiReportFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final consent = ref.watch(aiConsentStateProvider);
    final async = ref.watch(aiRoutinePlanControllerProvider);

    Widget card(List<Widget> children) => DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: space.x8,
          children: children,
        ),
      ),
    );

    Widget link(String label, VoidCallback onPressed) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: SaafButton.text(label: label, onPressed: onPressed),
    );

    if (consent == null) return const SizedBox.shrink();
    if (consent == false) {
      return card([
        Row(
          spacing: space.x8,
          children: [
            const ExcludeSemantics(child: Icon(Icons.auto_awesome)),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.aiPicksOfferTitle,
                  style: tokens.styles.listTitle,
                ),
              ),
            ),
          ],
        ),
        Text(l10n.aiPicksOfferBody, style: tokens.styles.pointCaption),
        link(l10n.aiPicksTurnOn, () => context.push(SaafRoute.aiCoach.path)),
      ]);
    }

    if (async.isLoading) {
      return card([
        Row(
          spacing: space.x8,
          children: [
            SizedBox.square(
              dimension: tokens.size.iconSmall,
              child: const CircularProgressIndicator(),
            ),
            Expanded(
              child: Text(
                l10n.aiPicksLoading,
                style: tokens.styles.pointCaption,
              ),
            ),
          ],
        ),
      ]);
    }

    if (async.hasError) {
      final failure = async.error;
      return card([
        Text(
          failure is Failure
              ? withDetail(l10n.aiPicksFailed, failure, show: Env.diagnostics)
              : l10n.aiPicksFailed,
          style: tokens.styles.pointCaption,
        ),
        link(
          l10n.scanTryAgain,
          () => ref.read(aiRoutinePlanControllerProvider.notifier).retry(),
        ),
      ]);
    }

    final plan = async.value;
    if (plan == null) return const SizedBox.shrink();

    // The AI picks actually in the routine (the phone may have left some out).
    final shown = <AiPick>[];
    for (final step in [...widget.routine.morning, ...widget.routine.night]) {
      final pick = plan.pickFor(step.product.id);
      if (pick != null && !shown.contains(pick)) shown.add(pick);
    }
    final profile = ref.watch(skinProfileControllerProvider);
    final hasProducts =
        (ref.watch(currentProductsProvider).value ?? const []).isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: space.x14,
      children: [
        card([
          Row(
            spacing: space.x8,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SaafChip(
                    label: l10n.aiPicksLabel,
                    icon: Icons.auto_awesome,
                    tone: SaafChipTone.cornsilk,
                    small: true,
                  ),
                ),
              ),
              if (_reported)
                Flexible(
                  child: Text(
                    l10n.aiReported,
                    style: tokens.styles.legal.copyWith(color: tokens.textMeta),
                  ),
                )
              else
                IconButton(
                  tooltip: l10n.aiReport,
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => _report(plan),
                ),
            ],
          ),
          if (plan.summary.isNotEmpty) SaafAiText(plan.summary),
          if (shown.isNotEmpty) ...[
            link(
              _open ? l10n.aiPicksHide : l10n.aiPicksWhy,
              () => setState(() => _open = !_open),
            ),
            if (_open)
              for (final pick in shown) _PickDetails(pick: pick),
          ],
          Text(
            l10n.aiPicksNote,
            style: tokens.styles.legal.copyWith(color: tokens.textMeta),
          ),
        ]),
        if (plan.current.isNotEmpty)
          card([
            Semantics(
              header: true,
              child: Text(l10n.currentTitle, style: tokens.styles.listTitle),
            ),
            for (final review in plan.current)
              _VerdictRow(review: review, caution: review.cautionFor(profile)),
            link(
              l10n.currentEdit,
              () => context.push(SaafRoute.myProducts.path),
            ),
          ])
        else if (!hasProducts)
          link(l10n.currentAdd, () => context.push(SaafRoute.myProducts.path)),
      ],
    );
  }
}

/// One AI pick: why it suits the user, what people say and where it came from.
class _PickDetails extends ConsumerWidget {
  const _PickDetails({required this.pick});

  final AiPick pick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x4,
      children: [
        Text(
          pick.product.name,
          // Product names are English web data.
          textDirection: TextDirection.ltr,
          style: tokens.styles.segment,
        ),
        if (pick.why.isNotEmpty)
          Text(pick.why, style: tokens.styles.pointCaption),
        if (pick.reviews.isNotEmpty)
          Text(
            l10n.aiPicksPeopleSay(pick.reviews),
            style: tokens.styles.pointCaption,
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SaafButton.text(
            label: l10n.checkPricesOnline,
            leadingIcon: Icons.open_in_new,
            onPressed: () => ref
                .read(externalLinkServiceProvider)
                .open(priceSearchUrl(pick.product.name)),
          ),
        ),
        if (pick.sources.isNotEmpty)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: tokens.space.x4,
            children: [
              Text(
                l10n.aiPicksSources,
                style: tokens.styles.legal.copyWith(color: tokens.textMeta),
              ),
              for (final url in pick.sources)
                Semantics(
                  label: l10n.aiPicksSourceLink(_site(url)),
                  excludeSemantics: true,
                  button: true,
                  child: SaafButton.text(
                    label: _site(url),
                    onPressed: () =>
                        ref.read(externalLinkServiceProvider).open(url),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// "reddit.com" from a full address.
  static String _site(String url) {
    final host = Uri.tryParse(url)?.host ?? url;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

/// Saaf AI's verdict on a product the user uses now, plus any warning the
/// phone adds from the safety answers (which Saaf AI never sees).
class _VerdictRow extends StatelessWidget {
  const _VerdictRow({required this.review, required this.caution});

  final CurrentProductReview review;
  final ProductCaution? caution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final (label, tone) = switch (review.verdict) {
      ProductVerdict.keep => (l10n.currentVerdictKeep, SaafChipTone.sage),
      ProductVerdict.replace => (
        l10n.currentVerdictReplace,
        SaafChipTone.papaya,
      ),
      ProductVerdict.stop => (l10n.currentVerdictStop, SaafChipTone.strong),
    };
    final warning = switch (caution) {
      ProductCaution.pregnancy => l10n.currentCautionPregnancy,
      ProductCaution.prescription => l10n.currentCautionPrescription,
      ProductCaution.sensitive => l10n.currentCautionSensitive,
      null => null,
    };

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space.x4,
        children: [
          Row(
            spacing: tokens.space.x8,
            children: [
              Expanded(
                child: Text(
                  review.name,
                  textDirection: TextDirection.ltr,
                  style: tokens.styles.segment,
                ),
              ),
              Flexible(
                child: SaafChip(label: label, tone: tone, small: true),
              ),
            ],
          ),
          if (review.why.isNotEmpty)
            Text(review.why, style: tokens.styles.pointCaption),
          if (review.reviews.isNotEmpty)
            Text(
              l10n.aiPicksPeopleSay(review.reviews),
              style: tokens.styles.pointCaption,
            ),
          if (review.replaceWith != null)
            Text(
              l10n.currentUseInstead(review.replaceWith!),
              style: tokens.styles.segment,
            ),
          if (warning != null)
            SaafMessageRow(
              icon: Icons.warning_amber_outlined,
              text: warning,
              color: context.colors.onSurface,
            ),
        ],
      ),
    );
  }
}
