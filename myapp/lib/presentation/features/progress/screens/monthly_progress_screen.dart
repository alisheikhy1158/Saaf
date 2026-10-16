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
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_before_after_slider.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_main_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_status_message.dart';

/// Figma 12 Monthly progress (a Saaf Pro feature): the latest face scan against
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

    final progress = view.progress;
    final fromText = date(progress.from);
    final biggest = progress.biggest;

    final summary = switch (progress.trend) {
      ProgressTrend.improving => l10n.progressSummaryImproving(
        _metricName(l10n, progress.mostImproved!.kind),
      ),
      ProgressTrend.steady => l10n.progressSummarySteady(fromText),
      ProgressTrend.slipping => l10n.progressSummarySlipping,
    };

    Future<void> share() => ref
        .read(shareServiceProvider)
        .shareText(
          l10n.progressShareText(
            view.month,
            _changeText(l10n, biggest[0]),
            _changeText(l10n, biggest[1]),
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
                  SaafOverline(l10n.progressMonth(view.month), strong: true),
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
            SaafIconButton(
              icon: Icons.ios_share,
              tooltip: l10n.progressShare,
              onPressed: share,
            ),
          ],
        ),
        SizedBox(height: space.x6),
        Text(
          l10n.progressRange(fromText, date(progress.to), 2),
          style: tokens.styles.meta.copyWith(color: tokens.textCaption),
        ),
        SizedBox(height: space.x16),
        SaafBeforeAfterSlider(
          before: _ScanImage(scan: view.before),
          after: _ScanImage(scan: view.after),
          beforeLabel: l10n.progressBefore(fromText),
          afterLabel: l10n.progressAfter(date(progress.to)),
          semanticLabel: l10n.progressCompare,
        ),
        SizedBox(height: space.x14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: space.rowGap,
            children: [
              for (final change in biggest)
                Expanded(
                  child: _ChangeCard(
                    name: _metricName(l10n, change.kind),
                    change: _signed(change.percent),
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
