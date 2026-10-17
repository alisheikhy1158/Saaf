import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/usecases/ask_coach.dart';
import 'package:saaf/presentation/providers/ai_chat_controller.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_ai_text.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// The AI skin coach: ask about a routine, an ingredient or a product, or attach
/// a photo. Before the first chat the user is told what is sent and who receives
/// it and must agree (Apple 5.1.2(i)); every answer is marked as AI and can be
/// reported (Google Play's AI-content policy); a standing reminder says it is
/// not medical advice (store-compliance §5).
class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

enum _Menu { newChat, stop }

enum _ReportReason { harmful, wrong, offensive, other }

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String get _language => Localizations.localeOf(context).languageCode;

  void _leave() =>
      context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    _input.clear();
    await ref
        .read(aiChatControllerProvider.notifier)
        .send(text, languageCode: _language);
  }

  Future<void> _attach() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<AiPhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.aiTakePhoto),
              onTap: () => Navigator.of(context).pop(AiPhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.aiChoosePhoto),
              onTap: () => Navigator.of(context).pop(AiPhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    await ref.read(aiChatControllerProvider.notifier).attach(source);
  }

  Future<void> _report(AiMessage reply) async {
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
    final sent = await ref
        .read(aiChatControllerProvider.notifier)
        .report(reply, reason.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? l10n.aiReportThanks : l10n.aiReportFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final consent = ref.watch(aiConsentStateProvider);

    ref.listen(aiChatControllerProvider, (before, now) {
      if (before == null ||
          before.messages.length != now.messages.length ||
          before.sending != now.sending) {
        _toEnd();
      }
    });

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.aiCoach.name}'),
      fixedBody: consent == true,
      topBar: SaafTopBar(
        title: l10n.aiTitle,
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: _leave),
        trailing: consent == true
            ? PopupMenuButton<_Menu>(
                tooltip: l10n.aiMenuTooltip,
                onSelected: (item) {
                  switch (item) {
                    case _Menu.newChat:
                      ref.read(aiChatControllerProvider.notifier).clear();
                    case _Menu.stop:
                      ref.read(aiConsentStateProvider.notifier).withdraw();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _Menu.newChat,
                    child: Text(l10n.aiMenuNewChat),
                  ),
                  PopupMenuItem(
                    value: _Menu.stop,
                    child: Text(l10n.aiMenuStop),
                  ),
                ],
              )
            : null,
      ),
      body: switch (consent) {
        null => const Center(child: CircularProgressIndicator()),
        false => _ConsentView(
          onAgree: () => ref.read(aiConsentStateProvider.notifier).give(),
          onLater: _leave,
        ),
        true => _ChatBody(
          scroll: _scroll,
          onSend: _send,
          onReport: _report,
          language: _language,
        ),
      },
      bottom: consent == true
          ? _Composer(input: _input, onSend: _send, onAttach: _attach)
          : const SizedBox.shrink(),
    );
  }
}

/// What is sent, who gets it, and the choice (before the first chat).
class _ConsentView extends StatelessWidget {
  const _ConsentView({required this.onAgree, required this.onLater});

  final VoidCallback onAgree;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    Widget section(String title, String body) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space.x4,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: context.text.titleSmall),
        ),
        Text(
          body,
          style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x16,
      children: [
        const Center(
          child: SaafIconCircle(
            icon: Icons.auto_awesome,
            size: SaafIconCircleSize.large,
          ),
        ),
        Semantics(
          header: true,
          child: Text(
            l10n.aiConsentTitle,
            textAlign: TextAlign.center,
            style: context.text.titleLarge,
          ),
        ),
        Text(
          l10n.aiConsentIntro,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
        ),
        section(l10n.aiConsentShareTitle, l10n.aiConsentShareBody),
        section(l10n.aiConsentWhoTitle, l10n.aiConsentWhoBody),
        Text(
          l10n.aiConsentChoice,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
        SaafButton.text(
          label: l10n.aiPolicyLink,
          onPressed: () => context.push(SaafRoute.privacyPolicy.path),
        ),
        SaafButton.primary(label: l10n.aiConsentAgree, onPressed: onAgree),
        SaafButton.text(label: l10n.scanNotNow, onPressed: onLater),
      ],
    );
  }
}

/// The conversation: reminder, messages (or the starting suggestions), the
/// error banner and the photos waiting to be sent.
class _ChatBody extends ConsumerWidget {
  const _ChatBody({
    required this.scroll,
    required this.onSend,
    required this.onReport,
    required this.language,
  });

  final ScrollController scroll;
  final Future<void> Function(String text) onSend;
  final Future<void> Function(AiMessage reply) onReport;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final chat = ref.watch(aiChatControllerProvider);
    final controller = ref.read(aiChatControllerProvider.notifier);

    final suggestions = [
      l10n.aiSuggestRoutine,
      l10n.aiSuggestDarkSpots,
      l10n.aiSuggestClash,
      l10n.aiSuggestSunscreen,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x8,
      children: [
        Text(
          l10n.aiDisclaimer,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
        Expanded(
          child: chat.messages.isEmpty && !chat.sending
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: tokens.space.x12,
                    children: [
                      SizedBox(height: tokens.space.x16),
                      const Center(
                        child: SaafIconCircle(
                          icon: Icons.auto_awesome,
                          size: SaafIconCircleSize.large,
                        ),
                      ),
                      Text(
                        l10n.aiEmptyTitle,
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge,
                      ),
                      Text(
                        l10n.aiEmptyBody,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(
                          color: tokens.textLabel,
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: tokens.space.x8,
                        runSpacing: tokens.space.x8,
                        children: [
                          for (final text in suggestions)
                            ActionChip(
                              label: Text(text),
                              onPressed: () => onSend(text),
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              : ListView(
                  controller: scroll,
                  children: [
                    for (final message in chat.messages)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: tokens.space.x8,
                        ),
                        child: _Bubble(message: message, onReport: onReport),
                      ),
                    if (chat.sending) const _Thinking(),
                  ],
                ),
        ),
        if (chat.failure != null)
          _FailureBanner(
            failure: chat.failure!,
            onRetry: () => controller.retry(languageCode: language),
          ),
        if (chat.photoFailed)
          Text(
            l10n.aiPhotoFailed,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
      ],
    );
  }
}

/// The message box: attach, type, send; with the photos waiting to be sent.
class _Composer extends ConsumerWidget {
  const _Composer({
    required this.input,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController input;
  final Future<void> Function(String text) onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final chat = ref.watch(aiChatControllerProvider);
    final controller = ref.read(aiChatControllerProvider.notifier);
    final canSend =
        !chat.sending &&
        (input.text.trim().isNotEmpty || chat.pendingPhotos.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x8,
      children: [
        if (chat.pendingPhotos.isNotEmpty)
          SizedBox(
            height: tokens.size.avatar,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, bytes) in chat.pendingPhotos.indexed)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: tokens.space.x8),
                    child: _PhotoThumb(
                      key: ValueKey('ai-photo-$i'),
                      bytes: bytes,
                      onRemove: () => controller.removePhoto(i),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: tokens.space.x8,
          children: [
            IconButton(
              tooltip: l10n.aiAttach,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed:
                  chat.sending ||
                      chat.pendingPhotos.length >= AskCoach.maxPhotos
                  ? null
                  : onAttach,
            ),
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey('ai-input'),
                child: TextField(
                  controller: input,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: AskCoach.maxTextLength,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) => null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) => canSend ? onSend(text) : null,
                  decoration: InputDecoration(hintText: l10n.aiInputHint),
                ),
              ),
            ),
            IconButton.filled(
              key: const ValueKey('ai-send'),
              tooltip: l10n.aiSend,
              icon: const Icon(Icons.arrow_upward),
              onPressed: canSend ? () => onSend(input.text) : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// One message: the user's on the end side, the AI's on the start side with its
/// "AI answer" label and the report button.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.onReport});

  final AiMessage message;
  final Future<void> Function(AiMessage reply) onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final user = message.isFromUser;
    final colors = context.colors;

    return Align(
      alignment: user
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: 0.88,
        alignment: user
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: user ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(tokens.radius.r18),
            border: user
                ? null
                : Border.all(
                    color: tokens.borderCard,
                    width: tokens.size.borderThin,
                  ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(tokens.space.x12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.space.x6,
              children: [
                if (!user)
                  Row(
                    children: [
                      SaafChip(
                        label: l10n.aiAnswerLabel,
                        tone: SaafChipTone.sageTint,
                        small: true,
                      ),
                      const Spacer(),
                      if (message.reported)
                        Text(
                          l10n.aiReported,
                          style: tokens.styles.legal.copyWith(
                            color: tokens.textMeta,
                          ),
                        )
                      else
                        IconButton(
                          tooltip: l10n.aiReport,
                          icon: const Icon(Icons.flag_outlined),
                          onPressed: () => onReport(message),
                        ),
                    ],
                  ),
                if (message.photoCount > 0)
                  Text(
                    l10n.aiPhotosAttached(message.photoCount),
                    style: tokens.styles.legal.copyWith(
                      color: user ? colors.onPrimary : tokens.textMeta,
                    ),
                  ),
                if (message.text.isNotEmpty && user)
                  Text(
                    message.text,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onPrimary,
                    ),
                  )
                else if (message.text.isNotEmpty)
                  SaafAiText(message.text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return Row(
      spacing: tokens.space.x8,
      children: [
        SizedBox.square(
          dimension: tokens.size.icon,
          child: const CircularProgressIndicator(),
        ),
        Text(l10n.aiThinking, style: context.text.bodyMedium),
      ],
    );
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final text = withDetail(
      switch (failure) {
        NetworkFailure() => l10n.aiErrorNetwork,
        RateLimited() => l10n.aiErrorLimit,
        ServiceUnavailable() => l10n.aiErrorUnavailable,
        Unauthorised() => l10n.aiErrorSignIn,
        _ => l10n.aiErrorGeneric,
      },
      failure,
      show: Env.diagnostics,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r18),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.x12),
        child: Row(
          spacing: tokens.space.x8,
          children: [
            Expanded(child: Text(text, style: context.text.bodyMedium)),
            if (failure is! RateLimited)
              TextButton(onPressed: onRetry, child: Text(l10n.scanTryAgain)),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.bytes, required this.onRemove, super.key});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.r14),
          child: Image.memory(
            bytes,
            width: tokens.size.avatar,
            height: tokens.size.avatar,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => SizedBox.square(
              dimension: tokens.size.avatar,
              child: const Icon(Icons.image_outlined),
            ),
          ),
        ),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: IconButton.filledTonal(
            tooltip: l10n.aiRemovePhoto,
            iconSize: tokens.size.iconSmall,
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
