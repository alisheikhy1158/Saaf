import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';
import 'package:saaf/presentation/providers/ai_chat_controller.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_before_after_slider.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_main_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';

/// Figma 12 Progress (a Saaf Pro feature; scans every two weeks, so it was
/// "Monthly progress" in the design): the latest face scan against
/// the one before it on a before / after slider, the two biggest changes and a
/// short coach summary. Free users see what Pro adds; with fewer than two scans
/// the screen explains what is needed.
class MonthlyProgressScreen extends ConsumerWidget {
  const MonthlyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final isPro = ref.watch(proStatusProvider);
    final async = isPro ? ref.watch(progressViewProvider) : null;
    final view = async?.value;

    final Widget body;
    if (!isPro) {
      body = SaafStatusMessage(
        icon: Icons.lock_outline,
        title: l10n.progressLockedTitle,
        body: l10n.progressLockedBody,
        actionLabel: l10n.progressLockedAction,
        onAction: () => context.push(SaafRoute.paywall.path),
      );
    } else if (async!.hasError && !async.hasValue) {
      body = SaafStatusMessage(
        icon: Icons.error_outline,
        title: l10n.progressErrorTitle,
        actionLabel: l10n.progressErrorAction,
        onAction: () => ref.invalidate(progressViewProvider),
      );
    } else if (async.isLoading && !async.hasValue) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(top: tokens.space.x36),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (view == null) {
      body = SaafStatusMessage(
        icon: Icons.compare_outlined,
        title: l10n.progressEmptyTitle,
        body: l10n.progressEmptyBody,
        actionLabel: l10n.progressEmptyAction,
        onAction: () => context.go(SaafRoute.selfieCapture.path),
      );
    } else {
      body = _Content(view: view);
    }

    return SaafMainNav(
      current: SaafMainTab.progress,
      child: SaafScaffold(
        key: ValueKey('screen-${SaafRoute.monthlyProgress.name}'),
        body: Padding(
          padding: EdgeInsetsDirectional.only(top: tokens.space.x8),
          child: body,
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.view});

  final ProgressView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context).toString();
    String date(DateTime d) => DateFormat('d MMM', locale).format(d);

    // Null until Saaf AI has analysed both scans: photos, but no numbers.
    final progress = view.progress;
    final fromText = date(view.before.takenAt);
    final toText = date(view.after.takenAt);

    Future<void> share(Progress progress) => ref
        .read(shareServiceProvider)
        .shareText(
          l10n.progressShareText(
            view.week,
            _changeText(l10n, progress.biggest[0]),
            _changeText(l10n, progress.biggest[1]),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: space.rowGap,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: space.x4,
                children: [
                  SaafOverline(l10n.progressWeek(view.week), strong: true),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.progressTitle,
                      style: context.text.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (progress != null)
              SaafIconButton(
                icon: Icons.ios_share,
                tooltip: l10n.progressShare,
                onPressed: () => share(progress),
              ),
          ],
        ),
        SizedBox(height: space.x6),
        Text(
          l10n.progressRange(fromText, toText, 2),
          style: tokens.styles.meta.copyWith(color: tokens.textCaption),
        ),
        SizedBox(height: space.x16),
        SaafBeforeAfterSlider(
          before: _ScanImage(scan: view.before),
          after: _ScanImage(scan: view.after),
          beforeLabel: l10n.progressBefore(fromText),
          afterLabel: l10n.progressAfter(toText),
          semanticLabel: l10n.progressCompare,
        ),
        SizedBox(height: space.x14),
        if (progress == null)
          _NotAnalysed(view: view)
        else
          _Changes(progress: progress, fromText: fromText),
        SizedBox(height: space.x12),
        _NextScan(latest: view.after.takenAt),
        SizedBox(height: space.x16),
        _AiReviewCard(view: view),
        SizedBox(height: space.x16),
        SaafButton.outline(
          label: l10n.progressCheckIn,
          onPressed: () => context.push(SaafRoute.weeklyCheckIn.path),
        ),
      ],
    );
  }

  static String _metricName(AppLocalizations l10n, SkinMetricKind kind) =>
      switch (kind) {
        SkinMetricKind.darkSpots => l10n.metricDarkSpots,
        SkinMetricKind.breakouts => l10n.metricBreakouts,
        SkinMetricKind.oiliness => l10n.metricOiliness,
        SkinMetricKind.hydration => l10n.metricHydration,
      };

  /// "−18%", "+6%", "0%" (a real minus sign, not a hyphen).
  static String _signed(int percent) => switch (percent) {
    < 0 => '−${percent.abs()}%',
    > 0 => '+$percent%',
    _ => '0%',
  };

  static String _changeText(AppLocalizations l10n, Change change) =>
      '${_metricName(l10n, change.kind)} ${_signed(change.percent)}';
}

/// One scan's front photo, filling the box (or a calm tint while it loads).
class _ScanImage extends ConsumerWidget {
  const _ScanImage({required this.scan});

  final CompletedScan scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = ColoredBox(color: context.saaf.sageTint);
    final photo = frontPhotoOf(scan);
    if (photo == null) return tint;

    final bytes = ref.watch(scanPhotoBytesProvider(photo)).value;
    if (bytes == null) return tint;
    return ExcludeSemantics(
      child: Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => tint,
      ),
    );
  }
}

class _ChangeCard extends StatelessWidget {
  const _ChangeCard({
    required this.name,
    required this.change,
    required this.since,
  });

  final String name;
  final String change;
  final String since;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return Semantics(
      container: true,
      label: l10n.progressChangeSemantics(name, change, since),
      excludeSemantics: true,
      child: SaafCard(
        padding: EdgeInsetsDirectional.all(tokens.space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.x2,
          children: [
            Text(
              name,
              style: tokens.styles.meta.copyWith(color: tokens.textSecondary),
            ),
            Text(change, style: context.text.headlineMedium),
            Text(
              since,
              style: tokens.styles.legal.copyWith(color: tokens.textMeta),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Next scan in 5 days", or "Your 2-week scan is due" with a Scan now button.
class _NextScan extends ConsumerWidget {
  const _NextScan({required this.latest});

  final DateTime latest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final days = daysUntilNextScan(latest, ref.watch(clockProvider).now());

    if (days > 0) {
      return Text(
        l10n.progressNextScan(days),
        textAlign: TextAlign.center,
        style: tokens.styles.meta.copyWith(color: tokens.textCaption),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x8,
      children: [
        Text(
          l10n.progressScanDue,
          textAlign: TextAlign.center,
          style: context.text.titleSmall,
        ),
        SaafButton.primary(
          label: l10n.progressScanNow,
          onPressed: () => context.go(SaafRoute.selfieCapture.path),
        ),
      ],
    );
  }
}

/// Lets the user send their first, previous and latest FRONT photos to the AI
/// coach for a plain-words review. Nothing is sent until they have seen the
/// photos and who receives them and tapped Send (store-compliance §5); before
/// they have agreed to the AI coach the button leads to its permission screen.
class _AiReviewCard extends ConsumerWidget {
  const _AiReviewCard({required this.view});

  final ProgressView view;

  /// The distinct scans to review, oldest first (at most three).
  List<CompletedScan> get _scans =>
      [
        for (final scan in [view.first, view.before, view.after]) scan,
      ].fold<List<CompletedScan>>([], (list, scan) {
        if (list.every((s) => s.id != scan.id)) list.add(scan);
        return list;
      });

  Future<void> _review(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    // The front photo of each scan, as it is on the phone.
    final shots = <({CompletedScan scan, Uint8List bytes})>[];
    for (final scan in _scans) {
      final photo = frontPhotoOf(scan);
      final bytes = photo == null
          ? null
          : await ref.read(scanPhotoBytesProvider(photo).future);
      if (bytes != null) shots.add((scan: scan, bytes: bytes));
    }
    if (!context.mounted) return;
    if (shots.isEmpty) {
      _say(context, l10n.progressAiPhotoError);
      return;
    }

    final go = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmSend(shots: shots),
    );
    if (go != true || !context.mounted) return;

    final shrinker = ref.read(photoShrinkerProvider);
    final small = <({CompletedScan scan, Uint8List bytes})>[];
    for (final shot in shots) {
      final bytes = await shrinker.shrink(shot.bytes);
      if (bytes != null) small.add((scan: shot.scan, bytes: bytes));
    }
    if (!context.mounted) return;
    if (small.isEmpty) {
      _say(context, l10n.progressAiPhotoError);
      return;
    }

    String date(DateTime d) => DateFormat('d MMM', locale.toString()).format(d);
    final lines = [
      for (final (i, shot) in small.indexed)
        i == 0
            ? l10n.aiReviewFirst(1, date(shot.scan.takenAt))
            : i == small.length - 1
            ? l10n.aiReviewLatest(i + 1, date(shot.scan.takenAt))
            : l10n.aiReviewMiddle(i + 1, date(shot.scan.takenAt)),
    ];
    final question = '${l10n.aiReviewQuestion} ${lines.join(' ')}';

    // Show the chat at once; the answer arrives there.
    unawaited(context.push(SaafRoute.aiCoach.path));
    await ref
        .read(aiChatControllerProvider.notifier)
        .reviewProgress(
          photos: [for (final shot in small) shot.bytes],
          question: question,
          languageCode: locale.languageCode,
        );
  }

  void _say(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final agreed = ref.watch(aiConsentStateProvider) == true;

    return SaafCard(
      padding: EdgeInsetsDirectional.all(tokens.space.x16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space.x8,
        children: [
          Row(
            spacing: tokens.space.x8,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.auto_awesome, size: tokens.size.iconSmall),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.progressAiTitle,
                    style: context.text.titleSmall,
                  ),
                ),
              ),
            ],
          ),
          Text(
            l10n.progressAiBody,
            style: context.text.bodyMedium?.copyWith(color: tokens.textLabel),
          ),
          agreed
              ? SaafButton.primary(
                  label: l10n.progressAiButton,
                  onPressed: () => _review(context, ref),
                )
              : SaafButton.outline(
                  label: l10n.progressAiSetup,
                  onPressed: () => context.push(SaafRoute.aiCoach.path),
                ),
        ],
      ),
    );
  }
}

/// The photos that will be sent, who receives them, and Cancel / Send.
class _ConfirmSend extends StatelessWidget {
  const _ConfirmSend({required this.shots});

  final List<({CompletedScan scan, Uint8List bytes})> shots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final locale = Localizations.localeOf(context).toString();

    return AlertDialog(
      title: Text(l10n.progressAiConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.x12,
          children: [
            Text(l10n.progressAiConfirmBody),
            Wrap(
              spacing: tokens.space.x8,
              runSpacing: tokens.space.x8,
              children: [
                for (final (i, shot) in shots.indexed)
                  Semantics(
                    label: l10n.progressAiPhotoSemantics(
                      DateFormat('d MMM', locale).format(shot.scan.takenAt),
                    ),
                    child: Column(
                      spacing: tokens.space.x2,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            tokens.radius.r14,
                          ),
                          child: Image.memory(
                            shot.bytes,
                            key: ValueKey('review-photo-$i'),
                            width: tokens.size.avatar,
                            height: tokens.size.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => SizedBox.square(
                              dimension: tokens.size.avatar,
                              child: const Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('d MMM', locale).format(shot.scan.takenAt),
                          style: tokens.styles.legal,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.progressAiSend),
        ),
      ],
    );
  }
}

/// The two biggest changes and the coach's summary (both scans analysed).
class _Changes extends StatelessWidget {
  const _Changes({required this.progress, required this.fromText});

  final Progress progress;
  final String fromText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final biggest = progress.biggest;
    final summary = switch (progress.trend) {
      ProgressTrend.improving => l10n.progressSummaryImproving(
        _Content._metricName(l10n, progress.mostImproved!.kind),
      ),
      ProgressTrend.steady => l10n.progressSummarySteady(fromText),
      ProgressTrend.slipping => l10n.progressSummarySlipping,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: space.rowGap,
            children: [
              for (final change in biggest)
                Expanded(
                  child: _ChangeCard(
                    name: _Content._metricName(l10n, change.kind),
                    change: _Content._signed(change.percent),
                    since: l10n.progressVs(fromText),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: space.rowGap),
        SaafInkCard(
          compact: true,
          padding: EdgeInsetsDirectional.all(space.planPaddingH),
          child: MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: space.x8,
              children: [
                Row(
                  spacing: space.x8,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.auto_awesome,
                        size: tokens.size.iconSmall,
                        color: tokens.onInkLabel,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.progressCoach,
                        style: tokens.styles.fieldLabel.copyWith(
                          color: tokens.onInkLabel,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  summary,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// No numbers until Saaf AI has read both scans' front photos (never a guess),
/// and a way to have it do so, asked before anything is sent.
class _NotAnalysed extends ConsumerStatefulWidget {
  const _NotAnalysed({required this.view});

  final ProgressView view;

  @override
  ConsumerState<_NotAnalysed> createState() => _NotAnalysedState();
}

class _NotAnalysedState extends ConsumerState<_NotAnalysed> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _analyse() async {
    final l10n = AppLocalizations.of(context);
    final estimates = await ref.read(aiSkinEstimatesProvider.future);
    final scans = [
      for (final scan in [widget.view.before, widget.view.after])
        if (estimates[scan.id] == null) scan,
    ];
    if (scans.isEmpty || !mounted) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.progressAnalyseConfirmTitle),
        content: Text(l10n.progressAnalyseConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.scanNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.resultsAnalyseSend),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    final language = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _failed = false;
    });
    var allOk = true;
    for (final scan in scans) {
      final result = await ref
          .read(aiSkinEstimatesProvider.notifier)
          .analyse(scan, languageCode: language);
      if (result.valueOrNull?.usable != true) allOk = false;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = !allOk;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final consent = ref.watch(aiConsentStateProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: space.x8,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.progressNotAnalysedTitle,
                style: tokens.styles.listTitle,
              ),
            ),
            Text(
              l10n.progressNotAnalysedBody,
              style: tokens.styles.pointCaption,
            ),
            if (_failed)
              SaafMessageRow(
                icon: Icons.warning_amber_outlined,
                text: l10n.progressAnalyseFailed,
                color: context.colors.onSurface,
              ),
            if (_busy)
              Row(
                spacing: space.x8,
                children: [
                  SizedBox.square(
                    dimension: tokens.size.iconSmall,
                    child: const CircularProgressIndicator(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.resultsAnalysing,
                      style: tokens.styles.pointCaption,
                    ),
                  ),
                ],
              )
            else if (consent == true)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SaafButton.text(
                  label: l10n.progressAnalyse,
                  onPressed: _analyse,
                ),
              )
            else if (consent == false)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SaafButton.text(
                  label: l10n.aiPicksTurnOn,
                  onPressed: () => context.push(SaafRoute.aiCoach.path),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
