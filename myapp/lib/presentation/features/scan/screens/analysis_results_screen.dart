import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/entities/stored_photo.dart';
import 'package:saaf/presentation/features/scan/widgets/skin_text.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_ai_text.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_disclaimer.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_ring.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 07 Analysis results: the score, the four measures and the way on to
/// the routine. Also the empty (no scan yet), loading and error states.
class AnalysisResultsScreen extends ConsumerWidget {
  const AnalysisResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final analysis = ref.watch(skinAnalysisProvider);
    final result = analysis.value;

    void back() =>
        context.canPop() ? context.pop() : context.go(SaafRoute.home.path);

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.analysisResults.name}'),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(tooltip: l10n.back, onBack: back),
        trailing: result == null
            ? null
            : SaafIconButton(
                icon: Icons.ios_share,
                tooltip: l10n.resultsShare,
                onPressed: () => _share(context, ref, result),
              ),
      ),
      body: analysis.hasError && !analysis.hasValue
          ? SaafStatusMessage(
              icon: Icons.error_outline,
              title: l10n.resultsErrorTitle,
              actionLabel: l10n.resultsErrorAction,
              onAction: () => ref.invalidate(skinAnalysisProvider),
            )
          : analysis.isLoading && !analysis.hasValue
          ? const _Loading()
          : result == null
          ? SaafStatusMessage(
              icon: Icons.photo_camera_outlined,
              title: l10n.resultsEmptyTitle,
              body: l10n.resultsEmptyBody,
              actionLabel: l10n.resultsEmptyAction,
              onAction: () => context.go(SaafRoute.selfieCapture.path),
            )
          : _Results(analysis: result),
      bottom: result == null
          ? null
          : SaafButton.primary(
              label: l10n.resultsSeeRoutine,
              trailingIcon: Icons.arrow_forward,
              onPressed: () => context.push(SaafRoute.routine.path),
            ),
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    SkinAnalysis analysis,
  ) async {
    final l10n = AppLocalizations.of(context);
    final separator = Localizations.localeOf(context).languageCode == 'ur'
        ? '، '
        : ', ';
    final focus = analysis.focus.map((m) => m.kind.label(l10n)).join(separator);
    await ref
        .read(shareServiceProvider)
        .shareText(l10n.resultsShareText(analysis.score, focus));
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(top: context.saaf.space.x36),
    child: const Center(child: CircularProgressIndicator()),
  );
}

class _Results extends StatelessWidget {
  const _Results({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SaafOverline(
          l10n.resultsOverline(_date(context, analysis.takenAt)),
          strong: true,
        ),
        SizedBox(height: space.x6),
        Semantics(
          header: true,
          child: Text(l10n.resultsTitle, style: tokens.styles.screenTitle),
        ),
        SizedBox(height: space.x18),
        _ScoreCard(analysis: analysis),
        SizedBox(height: space.x16),
        _SourceCard(analysis: analysis),
        SizedBox(height: space.sectionGapMedium),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.resultsConcerns,
                  style: context.text.titleSmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push(SaafRoute.howWeScore.path),
              style: TextButton.styleFrom(
                foregroundColor: tokens.textCaption,
                textStyle: tokens.styles.meta,
                minimumSize: Size(0, tokens.size.minTouchTarget),
                padding: EdgeInsetsDirectional.symmetric(horizontal: space.x8),
              ),
              child: Text(l10n.resultsHowWeScore),
            ),
          ],
        ),
        SizedBox(height: space.x12),
        _ConcernGrid(metrics: analysis.metrics),
        SizedBox(height: space.x16),
        if (analysis.source == AnalysisSource.aiPhoto) ...[
          _AiSeen(metrics: analysis.metrics),
          SizedBox(height: space.x16),
        ],
        SaafDisclaimer(l10n.resultsDisclaimer),
      ],
    );
  }

  /// "15 OCT 2026" (the overline upper-cases it).
  static String _date(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    try {
      return DateFormat('d MMM y', locale).format(date);
    } on Object {
      return DateFormat('d MMM y', 'en').format(date);
    }
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.analysis});

  final SkinAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final onInk = context.colors.onInverseSurface;

    final headline = switch (analysis.tone) {
      SkinTone.good => l10n.resultsHeadlineGood,
      SkinTone.fair => l10n.resultsHeadlineFair,
      SkinTone.needsCare => l10n.resultsHeadlineNeedsCare,
    };
    final focus = analysis.focus;

    return SaafInkCard(
      child: Row(
        spacing: tokens.space.x18,
        children: [
          SaafProgressRing(
            value: analysis.score / 100,
            size: tokens.size.scoreRing,
            stroke: tokens.size.scoreRingStroke,
            semanticLabel: l10n.resultsScoreSemantics(analysis.score),
            child: Padding(
              padding: EdgeInsets.all(
                tokens.size.scoreRingStroke + tokens.space.x4,
              ),
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${analysis.score}',
                      style: tokens.styles.scoreValue.copyWith(color: onInk),
                    ),
                    Text(
                      l10n.resultsScoreLabel,
                      style: tokens.styles.scoreLabel.copyWith(
                        color: tokens.onInkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.space.x6,
              children: [
                Text(
                  headline,
                  style: tokens.styles.cardHeadline.copyWith(color: onInk),
                ),
                if (focus.length == 2)
                  Text(
                    l10n.resultsFocus(
                      focus[0].kind.label(l10n),
                      focus[1].kind.label(l10n),
                    ),
                    style: tokens.styles.pointCaption.copyWith(
                      color: tokens.onInkLabel,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The measures two to a row, as in Figma.
class _ConcernGrid extends StatelessWidget {
  const _ConcernGrid({required this.metrics});

  final List<SkinMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final gap = context.saaf.space.x12;
    return Column(
      spacing: gap,
      children: [
        for (var i = 0; i < metrics.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: [
                Expanded(child: _ConcernCard(metric: metrics[i])),
                Expanded(
                  child: i + 1 < metrics.length
                      ? _ConcernCard(metric: metrics[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConcernCard extends StatelessWidget {
  const _ConcernCard({required this.metric});

  final SkinMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final name = metric.kind.label(l10n);
    final rating = metric.rating.label(l10n);
    final sure = switch (metric.confidence) {
      Confidence.low => l10n.resultsHowSure(l10n.confidenceLow),
      Confidence.medium => l10n.resultsHowSure(l10n.confidenceMedium),
      Confidence.high => l10n.resultsHowSure(l10n.confidenceHigh),
      null => null,
    };

    return Semantics(
      label: sure == null
          ? l10n.metricSemantics(name, rating)
          : '${l10n.metricSemantics(name, rating)}. $sure',
      excludeSemantics: true,
      child: SaafCard(
        padding: EdgeInsetsDirectional.all(tokens.space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.space.x8,
          children: [
            Text(name, style: tokens.styles.segment),
            Text(
              rating,
              style: tokens.styles.fieldLabel.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            SaafProgressBar(value: metric.amount, thick: true),
            if (sure != null)
              Text(
                sure,
                style: tokens.styles.legal.copyWith(color: tokens.textMeta),
              ),
          ],
        ),
      ),
    );
  }
}

/// Says plainly what the numbers are based on: a guess from the quiz (with a
/// way to have Saaf AI look at the front photo, asked before every send) or
/// Saaf AI's estimate from the photo (how accurate it is, a report button).
class _SourceCard extends ConsumerStatefulWidget {
  const _SourceCard({required this.analysis});

  final SkinAnalysis analysis;

  @override
  ConsumerState<_SourceCard> createState() => _SourceCardState();
}

enum _ReportReason { harmful, wrong, offensive, other }

class _SourceCardState extends ConsumerState<_SourceCard> {
  bool _busy = false;
  Failure? _failure;
  String? _problem;
  bool _reported = false;

  Future<void> _analyse() async {
    final l10n = AppLocalizations.of(context);
    final scan = ref.read(completedScanProvider);
    if (scan == null) return;
    final front = frontPhotoOf(scan);
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resultsAnalyseConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: context.saaf.space.x12,
            children: [
              if (front != null) _FrontThumb(photo: front),
              Text(l10n.resultsAnalyseConfirmBody),
            ],
          ),
        ),
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
    setState(() {
      _busy = true;
      _failure = null;
      _problem = null;
    });
    final result = await ref
        .read(aiSkinEstimatesProvider.notifier)
        .analyse(
          scan,
          languageCode: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failure = result.failureOrNull;
      final estimate = result.valueOrNull;
      if (estimate != null && !estimate.usable) _problem = estimate.problem;
    });
  }

  Future<void> _report() async {
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
    final analysis = widget.analysis;
    final text = [
      analysis.summary ?? '',
      for (final m in analysis.metrics)
        '${m.kind.name}: ${m.amount} (${m.confidence?.name}) ${m.seen ?? ''}',
    ].join('\n');
    final result = await ref
        .read(aiCoachServiceProvider)
        .report(
          reply: AiMessage(
            id: 'skin-${analysis.scanId}',
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
    final fromAi = widget.analysis.source == AnalysisSource.aiPhoto;

    Widget button(String label, VoidCallback onPressed) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: SaafButton.text(label: label, onPressed: onPressed),
    );

    final children = <Widget>[
      Row(
        spacing: space.x8,
        children: [
          ExcludeSemantics(
            child: Icon(
              fromAi ? Icons.auto_awesome : Icons.info_outline,
              size: tokens.size.icon,
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                fromAi ? l10n.resultsAiTitle : l10n.resultsQuizEstimateTitle,
                style: tokens.styles.listTitle,
              ),
            ),
          ),
          if (fromAi)
            _reported
                ? Flexible(
                    child: Text(
                      l10n.aiReported,
                      style: tokens.styles.legal.copyWith(
                        color: tokens.textMeta,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: l10n.aiReport,
                    icon: const Icon(Icons.flag_outlined),
                    onPressed: _report,
                  ),
        ],
      ),
      if (fromAi && widget.analysis.summary != null)
        Text(widget.analysis.summary!, style: tokens.styles.pointCaption),
      Text(
        fromAi ? l10n.resultsAiAccuracy : l10n.resultsQuizEstimateBody,
        style: tokens.styles.pointCaption,
      ),
      if (!fromAi) ...[
        if (_problem != null)
          SaafMessageRow(
            icon: Icons.warning_amber_outlined,
            text: l10n.resultsAnalyseUnusable(_problem!),
            color: context.colors.onSurface,
          ),
        if (_failure != null)
          SaafMessageRow(
            icon: Icons.error_outline,
            text: withDetail(
              switch (_failure!) {
                NetworkFailure() => l10n.aiErrorNetwork,
                RateLimited() => l10n.aiErrorLimit,
                ServiceUnavailable() => l10n.aiErrorUnavailable,
                Unauthorised() => l10n.aiErrorSignIn,
                _ => l10n.aiErrorGeneric,
              },
              _failure!,
              show: Env.diagnostics,
            ),
            color: context.colors.error,
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
          button(l10n.resultsAnalysePhoto, _analyse)
        else if (consent == false)
          button(
            l10n.aiPicksTurnOn,
            () => context.push(SaafRoute.aiCoach.path),
          ),
      ],
    ];

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
          children: children,
        ),
      ),
    );
  }
}

/// The front photo that would be sent, in the confirm dialog.
class _FrontThumb extends ConsumerWidget {
  const _FrontThumb({required this.photo});

  final StoredPhoto photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final bytes = ref.watch(scanPhotoBytesProvider(photo)).value;
    return Semantics(
      image: true,
      label: l10n.resultsFrontPhotoLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius.r14),
        child: SizedBox.square(
          dimension: tokens.size.productImage,
          child: bytes == null
              ? const Icon(Icons.image_outlined)
              : Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.image_outlined),
                ),
        ),
      ),
    );
  }
}

/// What Saaf AI saw for each measure (AI estimates only).
class _AiSeen extends StatelessWidget {
  const _AiSeen({required this.metrics});

  final List<SkinMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final lines = [
      for (final m in metrics)
        if (m.seen != null) '- **${m.kind.label(l10n)}:** ${m.seen}',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x8,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.resultsAiSeen, style: context.text.titleSmall),
        ),
        SaafAiText(lines.join('\n')),
      ],
    );
  }
}
