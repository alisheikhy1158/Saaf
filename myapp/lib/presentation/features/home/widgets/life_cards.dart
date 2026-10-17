import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/introduction.dart';
import 'package:saaf/domain/entities/life_event.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/life_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';

/// Home: the new product being introduced (with the daily check-in), the
/// event countdown and Ramadan tips; each only when it applies.
class LifeCards extends ConsumerWidget {
  const LifeCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final intro = ref.watch(introductionControllerProvider).value;
    final event = ref.watch(lifeEventControllerProvider).value;
    final ramadan = ref.watch(ramadanModeProvider).value == true;

    final cards = [
      if (intro != null) _IntroCard(intro: intro, now: now),
      if (event != null && event.stageOn(now) != EventStage.over)
        _EventCard(event: event, now: now),
      if (ramadan) const _RamadanCard(),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.saaf.space.x14,
      children: cards,
    );
  }
}

class _LifeCard extends StatelessWidget {
  const _LifeCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
        border: Border.all(
          color: tokens.borderCard,
          width: tokens.size.borderThin,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.space.x8,
          children: [
            Row(
              spacing: tokens.space.x8,
              children: [
                ExcludeSemantics(child: Icon(icon)),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: tokens.styles.listTitle),
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends ConsumerWidget {
  const _IntroCard({required this.intro, required this.now});

  final Introduction intro;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final controller = ref.read(introductionControllerProvider.notifier);
    final stage = intro.stageOn(now);
    final name = intro.productName;

    final text = switch (stage) {
      IntroStage.patchTest => l10n.introPatchTest,
      IntroStage.twiceAWeek => l10n.introTwiceAWeek,
      IntroStage.everyOtherNight => l10n.introEveryOtherNight,
      IntroStage.paused => l10n.introPaused,
      IntroStage.stopped => l10n.introStopped(name),
      IntroStage.done => l10n.introDone(name),
    };
    final finished = stage == IntroStage.stopped || stage == IntroStage.done;

    return _LifeCard(
      icon: Icons.science_outlined,
      title: l10n.introTitle(name),
      children: [
        Text(text, style: tokens.styles.pointCaption),
        if (intro.needsCheckIn(now)) ...[
          Text(l10n.introAsk, style: tokens.styles.segment),
          Wrap(
            spacing: tokens.space.x8,
            runSpacing: tokens.space.x8,
            children: [
              for (final (reaction, label) in [
                (Reaction.none, l10n.introNone),
                (Reaction.mild, l10n.introMild),
                (Reaction.strong, l10n.introStrong),
              ])
                SaafButton.outline(
                  label: label,
                  onPressed: () => controller.answer(reaction),
                ),
            ],
          ),
        ],
        if (finished)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaafButton.text(
              label: l10n.commonDone,
              onPressed: controller.clear,
            ),
          ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.now});

  final LifeEvent event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final stage = event.stageOn(now);
    return _LifeCard(
      icon: Icons.celebration_outlined,
      title: stage == EventStage.today
          ? l10n.eventToday(event.name)
          : l10n.eventCountdown(event.name, event.daysLeft(now)),
      children: [
        Text(switch (stage) {
          EventStage.buildRoutine => l10n.eventBuildRoutine,
          EventStage.lastNewProduct => l10n.eventLastNewProduct,
          EventStage.noNewActives => l10n.eventNoNewActives,
          EventStage.nothingNew => l10n.eventNothingNew,
          EventStage.gentleWeek => l10n.eventGentleWeek,
          EventStage.today || EventStage.over => l10n.eventTodayTip,
        }, style: tokens.styles.pointCaption),
      ],
    );
  }
}

class _RamadanCard extends StatelessWidget {
  const _RamadanCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return _LifeCard(
      icon: Icons.nights_stay_outlined,
      title: l10n.ramadanTitle,
      children: [
        for (final tip in [
          l10n.ramadanTipWater,
          l10n.ramadanTipSimple,
          l10n.ramadanTipSunscreen,
        ])
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space.x8,
            children: [
              ExcludeSemantics(
                child: Text('•', style: tokens.styles.pointCaption),
              ),
              Expanded(child: Text(tip, style: tokens.styles.pointCaption)),
            ],
          ),
      ],
    );
  }
}
