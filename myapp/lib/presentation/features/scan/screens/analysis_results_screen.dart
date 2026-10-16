import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/presentation/features/scan/widgets/skin_text.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_disclaimer.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
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

    return Semantics(
      label: l10n.metricSemantics(name, rating),
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
          ],
        ),
      ),
    );
  }
}
