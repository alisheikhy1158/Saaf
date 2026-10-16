import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
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
              label: l10n.routineMorning,
              icon: Icons.wb_sunny_outlined,
            ),
            SaafSegment(
              label: l10n.routineNight,
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
            _rs(l10n, locale, step.product.pricePkr),
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
