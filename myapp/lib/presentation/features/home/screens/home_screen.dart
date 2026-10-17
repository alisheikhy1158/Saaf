import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/features/home/widgets/skin_weather_card.dart';
import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/routine.dart';
import 'package:saaf/presentation/features/home/controllers/home_controller.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_main_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_ring.dart';
import 'package:saaf/presentation/widgets/common/saaf_routine_step_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';

/// Figma 09 Home: greeting, this week, today's progress and the checklist for
/// the morning or night routine. Also the loading, empty and error states.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(homeControllerProvider);
    final state = async.value;

    return SaafMainNav(
      current: SaafMainTab.home,
      child: SaafScaffold(
        key: ValueKey('screen-${SaafRoute.home.name}'),
        body: async.hasError && !async.hasValue
            ? SaafStatusMessage(
                icon: Icons.error_outline,
                title: l10n.homeErrorTitle,
                actionLabel: l10n.homeErrorAction,
                onAction: () => ref.invalidate(homeControllerProvider),
              )
            : state == null
            ? Padding(
                padding: EdgeInsetsDirectional.only(
                  top: context.saaf.space.x36,
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            : !state.hasRoutine
            ? SaafStatusMessage(
                icon: Icons.spa_outlined,
                title: l10n.routineEmptyTitle,
                body: l10n.routineEmptyBody,
                actionLabel: l10n.routineEmptyAction,
                onAction: () => context.go(SaafRoute.skinQuiz.path),
              )
            : _Content(state: state),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();
    final name = _firstName(
      ref.watch(authSessionControllerProvider)?.displayName,
    );
    final controller = ref.read(homeControllerProvider.notifier);

    final percent = (state.progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: space.x8),
        Row(
          spacing: space.rowGap,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: space.x2,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM', locale).format(state.today),
                    style: tokens.styles.meta.copyWith(
                      color: tokens.textCaption,
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      name == null
                          ? l10n.homeGreetingNoName
                          : l10n.homeGreeting(name),
                      style: context.text.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            SaafIconButton(
              icon: Icons.auto_awesome,
              tooltip: l10n.homeAiTooltip,
              onPressed: () => context.push(SaafRoute.aiCoach.path),
            ),
            SaafIconButton(
              icon: Icons.qr_code_scanner,
              tooltip: l10n.homeScanTooltip,
              onPressed: () => context.push(SaafRoute.scanProduct.path),
            ),
            SaafIconButton(
              icon: Icons.notifications_none,
              tooltip: l10n.routineReminders,
              // Reminders are set up in the profile (14).
              onPressed: () => context.push(SaafRoute.profile.path),
            ),
          ],
        ),
        SizedBox(height: space.x18),
        _WeekStrip(state: state),
        SizedBox(height: space.x16),
        SaafInkCard(
          child: Row(
            spacing: space.x16,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: space.x6,
                  children: [
                    Text(
                      l10n.homeProgressLabel,
                      style: tokens.styles.meta.copyWith(
                        color: tokens.onInkSecondary,
                      ),
                    ),
                    Text(
                      l10n.homeStepsDone(state.doneCount, state.steps.length),
                      style: context.text.titleLarge?.copyWith(
                        color: context.colors.onInverseSurface,
                      ),
                    ),
                    SizedBox(height: space.x4),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: tokens.size.progressBarWide,
                      ),
                      child: SaafProgressBar(
                        value: state.progress,
                        onInk: true,
                      ),
                    ),
                  ],
                ),
              ),
              SaafProgressRing(
                value: state.progress,
                size: tokens.size.progressRing,
                stroke: tokens.size.progressRingStroke,
                semanticLabel: l10n.homeProgressSemantics(percent),
                child: Padding(
                  padding: EdgeInsets.all(tokens.size.progressRingStroke),
                  child: FittedBox(
                    child: Text(
                      NumberFormat.percentPattern(
                        locale,
                      ).format(state.progress),
                      style: tokens.styles.ringValue.copyWith(
                        color: context.colors.onInverseSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: space.sectionGapMedium),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.homeRoutineTitle,
                  style: context.text.titleSmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
            _TimeChip(
              time: state.time,
              onPressed: () => controller.selectTime(
                state.time == RoutineTime.morning
                    ? RoutineTime.night
                    : RoutineTime.morning,
              ),
            ),
          ],
        ),
        SizedBox(height: space.x10),
        _Checklist(state: state),
        SizedBox(height: space.sectionGapMedium),
        const SkinWeatherCard(),
      ],
    );
  }

  /// "Ayesha Khan" → "Ayesha".
  static String? _firstName(String? displayName) {
    final first = displayName?.trim().split(RegExp(r'\s+')).first;
    return first == null || first.isEmpty ? null : first;
  }
}

/// Monday to Sunday, today filled in ink.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();

    return Semantics(
      container: true,
      label: l10n.homeWeekLabel,
      child: LayoutBuilder(
        builder: (context, box) {
          // 44 dp pills; they narrow a little on small phones to fit seven.
          final minGap = tokens.space.x4;
          final width = math.min(
            tokens.size.dayWidth,
            (box.maxWidth - minGap * 6) / 7,
          );
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in state.week)
                _DayPill(
                  width: width,
                  letter: DateFormat.EEEEE(locale).format(day),
                  number: NumberFormat.decimalPattern(locale).format(day.day),
                  isToday: sameDay(day, state.today),
                  isComplete: state.isDayComplete(day),
                  spoken: _spoken(l10n, locale, day, state),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _spoken(
    AppLocalizations l10n,
    String locale,
    DateTime day,
    HomeState state,
  ) {
    final label = DateFormat('EEEE d', locale).format(day);
    if (sameDay(day, state.today)) return l10n.homeToday(label);
    return state.isDayComplete(day)
        ? l10n.homeDayComplete(label)
        : l10n.homeDayOpen(label);
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.width,
    required this.letter,
    required this.number,
    required this.isToday,
    required this.isComplete,
    required this.spoken,
  });

  final double width;
  final String letter;
  final String number;
  final bool isToday;
  final bool isComplete;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;

    final letterColor = isToday ? tokens.onInkLabel : tokens.textMeta;
    final numberColor = isToday ? colors.onInverseSurface : colors.onSurface;
    final dotColor = isComplete
        ? tokens.sage
        : (isToday ? tokens.trackOnInk : tokens.divider);

    return Semantics(
      container: true,
      label: spoken,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isToday ? colors.inverseSurface : null,
          borderRadius: BorderRadius.circular(tokens.radius.r22),
          border: isToday
              ? null
              : Border.all(
                  color: tokens.borderCard,
                  width: tokens.size.borderThin,
                ),
        ),
        child: SizedBox(
          width: width,
          height: tokens.size.dayHeight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.all(tokens.space.x2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: tokens.space.x4,
                children: [
                  Text(
                    letter,
                    style: tokens.styles.micro.copyWith(color: letterColor),
                  ),
                  Text(
                    number,
                    style: tokens.styles.listTitle.copyWith(color: numberColor),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: tokens.size.dayDot),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Morning" / "Night" chip: shows which routine is listed and switches to
/// the other one when tapped.
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.onPressed});

  final RoutineTime time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final isMorning = time == RoutineTime.morning;
    final other = isMorning ? l10n.routineNight : l10n.routineMorning;

    return Tooltip(
      message: l10n.homeSwitchTime(other),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(tokens.radius.r18),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
          child: Center(
            widthFactor: 1,
            child: SaafChip(
              label: isMorning ? l10n.routineMorning : l10n.routineNight,
              icon: isMorning
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_outlined,
              tone: SaafChipTone.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Checklist extends ConsumerWidget {
  const _Checklist({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();
    final controller = ref.read(homeControllerProvider.notifier);
    final steps = state.steps;

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
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.space.groupPaddingH,
          vertical: tokens.space.checklistPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, step) in steps.indexed)
              _ChecklistRow(
                step: step,
                locale: locale,
                l10n: l10n,
                done: state.isDone(step),
                isLast: i == steps.length - 1,
                onTap: () => controller.toggle(step),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.step,
    required this.locale,
    required this.l10n,
    required this.done,
    required this.isLast,
    required this.onTap,
  });

  final RoutineStep step;
  final String locale;
  final AppLocalizations l10n;
  final bool done;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = switch (step.category) {
      ProductCategory.cleanser => l10n.stepCleanser,
      ProductCategory.treatment => l10n.stepTreatment,
      ProductCategory.moisturiser => l10n.stepMoisturiser,
      ProductCategory.sunscreen => l10n.stepSunscreen,
    };
    // The user's own product, or one from the web (no price).
    final price = OwnedProduct.isOwned(step.product)
        ? l10n.routineYours
        : step.product.pricePkr == 0
        ? l10n.productCheckPrice
        : l10n.priceRs(
            NumberFormat.decimalPattern(locale).format(step.product.pricePkr),
          );
    final name = step.product.name;

    return SaafRoutineStepRow(
      name: name,
      caption: l10n.homeStepCaption(category, price),
      isLast: isLast,
      checked: done,
      semanticLabel: done
          ? l10n.homeStepDone(name)
          : l10n.homeStepNotDone(name),
      onTap: onTap,
      trailing: SaafCheck(
        checked: done,
        shape: SaafCheckShape.circle,
        size: SaafCheckSize.large,
      ),
    );
  }
}
