import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/breakpoints.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/presentation/features/coach/controllers/check_in_controller.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 11 Weekly check-in: a short chat with the Saaf coach. Two questions
/// answered with quick replies (or typed), then a "Likely on track" style
/// result. The coach follows fixed rules and uses no AI, so nothing is sent to a
/// third party (store-compliance §5).
class WeeklyCheckInScreen extends ConsumerStatefulWidget {
  const WeeklyCheckInScreen({super.key});

  @override
  ConsumerState<WeeklyCheckInScreen> createState() =>
      _WeeklyCheckInScreenState();
}

class _WeeklyCheckInScreenState extends ConsumerState<WeeklyCheckInScreen> {
  final _scroll = ScrollController();
  final _reply = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    _reply.dispose();
    super.dispose();
  }

  void _send() {
    final text = _reply.text;
    if (text.trim().isEmpty) return;
    ref.read(checkInControllerProvider.notifier).sendText(text);
    _reply.clear();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _showInfo() {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.checkInInfoTitle),
        content: Text(l10n.checkInInfoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.checkInInfoClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final state = ref.watch(checkInControllerProvider);
    final controller = ref.read(checkInControllerProvider.notifier);
    final gutter = SaafBreakpoint.gutterFor(MediaQuery.sizeOf(context).width);

    ref.listen(checkInControllerProvider, (_, _) => _scrollToEnd());

    void back() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

    return Scaffold(
      key: ValueKey('screen-${SaafRoute.weeklyCheckIn.name}'),
      body: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SaafBreakpoint.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
              child: Column(
                children: [
                  SaafTopBar(
                    title: l10n.checkInTitle,
                    leading: SaafTopBar.backButton(
                      tooltip: l10n.back,
                      onBack: back,
                    ),
                    trailing: SaafIconButton(
                      icon: Icons.info_outline,
                      tooltip: l10n.checkInInfo,
                      onPressed: _showInfo,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SaafChip(
                              label: l10n.checkInWeek(state.week),
                              tone: SaafChipTone.sageTint,
                            ),
                          ),
                          SizedBox(height: space.x18),
                          Column(
                            spacing: space.x12,
                            children: [
                              for (final item in state.messages)
                                _Bubble(item: item),
                            ],
                          ),
                          if (state.outcome != null) ...[
                            SizedBox(height: space.x16),
                            _ResultCard(state: state),
                          ],
                          if (state.step != CheckInStep.done) ...[
                            SizedBox(height: space.x16),
                            _QuickReplies(
                              state: state,
                              onFeel: controller.answerSkinFeel,
                              onBreakouts: controller.answerBreakouts,
                            ),
                          ],
                          SizedBox(height: space.x16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: space.x8,
                      bottom: space.pageBottom,
                    ),
                    child: _ReplyField(controller: _reply, onSend: _send),
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

/// One chat message: the coach on the start side with an avatar, the user on
/// the end side in ink.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.item});

  final ChatItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final colors = context.colors;

    final (String text, bool fromUser) = switch (item) {
      CoachGreeting(:final name) => (
        name == null ? l10n.checkInGreetingNoName : l10n.checkInGreeting(name),
        false,
      ),
      CoachBreakoutsQuestion(:final after) => (
        switch (after) {
          SkinFeel.lessOily => l10n.checkInQ2Nice,
          SkinFeel.drier => l10n.checkInQ2Noted,
          SkinFeel.irritated => l10n.checkInQ2Sorry,
          SkinFeel.same || SkinFeel.other => l10n.checkInQ2Thanks,
        },
        false,
      ),
      CoachNoteSaved() => (l10n.checkInNoteSaved, false),
      UserSkinFeel(:final value) => (_feelLabel(l10n, value), true),
      UserBreakouts(:final value) => (_breakoutLabel(l10n, value), true),
      UserText(:final text) => (text, true),
    };

    final radius = tokens.radius;
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: fromUser ? colors.inverseSurface : colors.surface,
        border: fromUser
            ? null
            : Border.all(
                color: tokens.borderCard,
                width: tokens.size.borderThin,
              ),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(radius.r18),
          topEnd: Radius.circular(radius.r18),
          bottomStart: Radius.circular(fromUser ? radius.r18 : radius.r6),
          bottomEnd: Radius.circular(fromUser ? radius.r6 : radius.r18),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: fromUser ? tokens.space.x16 : tokens.space.x14,
          vertical: tokens.space.x12,
        ),
        child: Text(
          text,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: fromUser ? FontWeight.w700 : null,
            color: fromUser ? colors.onInverseSurface : colors.onSurface,
          ),
        ),
      ),
    );

    final label = fromUser
        ? l10n.checkInYouSaid(text)
        : l10n.checkInCoachSays(text);
    final limit = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.size.chatBubbleMaxWidth),
      child: bubble,
    );

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: fromUser
          ? Align(alignment: AlignmentDirectional.centerEnd, child: limit)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: tokens.space.x10,
              children: [
                _Avatar(letter: l10n.checkInCoachInitial),
                Flexible(child: limit),
              ],
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: tokens.size.chatAvatar,
        child: DecoratedBox(
          decoration: BoxDecoration(color: tokens.sage, shape: BoxShape.circle),
          child: Center(
            child: Text(
              letter,
              style: tokens.styles.listTitle.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _feelLabel(AppLocalizations l10n, SkinFeel value) => switch (value) {
  SkinFeel.lessOily => l10n.checkInFeelLessOily,
  SkinFeel.same => l10n.checkInFeelSame,
  SkinFeel.drier => l10n.checkInFeelDrier,
  SkinFeel.irritated => l10n.checkInFeelIrritated,
  SkinFeel.other => '',
};

String _breakoutLabel(AppLocalizations l10n, BreakoutChange value) =>
    switch (value) {
      BreakoutChange.none => l10n.checkInBreakNone,
      BreakoutChange.fewSmall => l10n.checkInBreakFew,
      BreakoutChange.more => l10n.checkInBreakMore,
      BreakoutChange.severe => l10n.checkInBreakSevere,
      BreakoutChange.other => '',
    };

/// The answers on offer for the question that is waiting, as tappable chips.
class _QuickReplies extends StatelessWidget {
  const _QuickReplies({
    required this.state,
    required this.onFeel,
    required this.onBreakouts,
  });

  final CheckInState state;
  final ValueChanged<SkinFeel> onFeel;
  final ValueChanged<BreakoutChange> onBreakouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    final replies = state.step == CheckInStep.skinFeel
        ? [
            for (final v in [
              SkinFeel.lessOily,
              SkinFeel.same,
              SkinFeel.drier,
              SkinFeel.irritated,
            ])
              (_feelLabel(l10n, v), () => onFeel(v)),
          ]
        : [
            for (final v in [
              BreakoutChange.none,
              BreakoutChange.fewSmall,
              BreakoutChange.more,
              BreakoutChange.severe,
            ])
              (_breakoutLabel(l10n, v), () => onBreakouts(v)),
          ];

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: tokens.space.x8,
      children: [
        for (final (label, onTap) in replies)
          Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            onTap: onTap,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(tokens.radius.r18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: tokens.size.minTouchTarget,
                ),
                child: Center(
                  widthFactor: 1,
                  child: SaafChip(label: label, tone: SaafChipTone.outline),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Likely on track" and what it is based on.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final CheckInState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();
    final outcome = state.outcome!;
    final answers = state.answers;

    final title = switch (outcome) {
      CheckInOutcome.onTrack => l10n.checkInOnTrack,
      CheckInOutcome.keepGoing => l10n.checkInKeepGoing,
      CheckInOutcome.adjust => l10n.checkInAdjust,
      CheckInOutcome.seeProfessional => l10n.checkInSeePro,
    };
    final body = [
      switch (answers.skinFeel) {
        SkinFeel.lessOily => l10n.checkInSentenceLessOily,
        SkinFeel.same => l10n.checkInSentenceSame,
        SkinFeel.drier => l10n.checkInSentenceDrier,
        SkinFeel.irritated => l10n.checkInSentenceIrritated,
        SkinFeel.other || null => null,
      },
      switch (answers.breakouts) {
        BreakoutChange.none => l10n.checkInSentenceNone,
        BreakoutChange.fewSmall => l10n.checkInSentenceFew(state.week),
        BreakoutChange.more => l10n.checkInSentenceMore,
        BreakoutChange.severe => l10n.checkInSentenceSevere,
        BreakoutChange.other || null => null,
      },
      switch (outcome) {
        CheckInOutcome.onTrack => l10n.checkInAdviceOnTrack,
        CheckInOutcome.keepGoing => l10n.checkInAdviceKeepGoing,
        CheckInOutcome.adjust => l10n.checkInAdviceAdjust,
        CheckInOutcome.seeProfessional => l10n.checkInAdviceSeePro,
      },
    ].whereType<String>().join(' ');

    final next = state.nextPhotoCheck;

    return Semantics(
      container: true,
      label: l10n.checkInResultSemantics(title, body),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.sageTint,
          borderRadius: BorderRadius.circular(tokens.radius.r22),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.space.planPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space.optionGap,
            children: [
              Row(
                spacing: tokens.space.optionGap,
                children: [
                  const SaafIconCircle(
                    icon: Icons.auto_awesome,
                    size: SaafIconCircleSize.compact,
                  ),
                  Expanded(child: Text(title, style: context.text.titleMedium)),
                ],
              ),
              Text(
                body,
                style: context.text.bodyMedium?.copyWith(
                  color: tokens.textLabel,
                ),
              ),
              if (next != null)
                SaafChip(
                  label: l10n.checkInNextPhoto(
                    DateFormat('d MMM', locale).format(next),
                  ),
                  icon: Icons.photo_camera_outlined,
                  tone: SaafChipTone.cornsilk,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pill at the bottom: a text field and the round send button.
class _ReplyField extends StatelessWidget {
  const _ReplyField({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radius.r28),
        border: Border.all(
          color: tokens.borderStrong,
          width: tokens.size.borderThin,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.size.input),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: tokens.space.x20),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  minLines: 1,
                  maxLines: 3,
                  style: tokens.styles.inputText,
                  decoration: InputDecoration(
                    hintText: l10n.checkInHint,
                    hintStyle: tokens.styles.inputText.copyWith(
                      color: tokens.textOverline,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    // The theme's 56 dp minimum would pin the text to the top.
                    constraints: const BoxConstraints(),
                    contentPadding: EdgeInsetsDirectional.zero,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: (tokens.size.input - tokens.size.sendButton) / 2,
              ),
              child: IconButton(
                tooltip: l10n.checkInSend,
                onPressed: onSend,
                icon: Icon(Icons.arrow_upward, size: tokens.size.iconCamera),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  fixedSize: Size.square(tokens.size.sendButton),
                  minimumSize: Size.square(tokens.size.sendButton),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
