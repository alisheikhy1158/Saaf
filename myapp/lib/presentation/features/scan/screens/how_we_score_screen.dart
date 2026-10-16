import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// "How we score": what the score means, what is measured and how the number
/// is made. Opened from the Concerns heading on the results screen.
class HowWeScoreScreen extends StatelessWidget {
  const HowWeScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.howWeScore.name}'),
      topBar: SaafTopBar.back(
        tooltip: l10n.back,
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(SaafRoute.analysisResults.path),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.howWeScoreTitle, style: tokens.styles.screenTitle),
          ),
          SizedBox(height: space.x12),
          Text(l10n.howWeScoreIntro, style: context.text.bodyLarge),
          _Section(
            title: l10n.howWeScoreLooksTitle,
            bullets: [
              l10n.howWeScoreSpots,
              l10n.howWeScoreBreakouts,
              l10n.howWeScoreOil,
              l10n.howWeScoreHydration,
            ],
          ),
          _Section(
            title: l10n.howWeScoreMathTitle,
            paragraphs: [l10n.howWeScoreMath],
          ),
          _Section(
            title: l10n.howWeScorePhotosTitle,
            paragraphs: [l10n.howWeScorePhotos],
          ),
          _Section(
            title: l10n.howWeScoreMedicalTitle,
            paragraphs: [l10n.howWeScoreMedical],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: tokens.space.sectionGapMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space.x8,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.text.titleSmall),
          ),
          for (final paragraph in paragraphs)
            Text(paragraph, style: context.text.bodyMedium),
          for (final bullet in bullets)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.space.x8,
              children: [
                ExcludeSemantics(
                  child: Text('•', style: context.text.bodyMedium),
                ),
                Expanded(child: Text(bullet, style: context.text.bodyMedium)),
              ],
            ),
        ],
      ),
    );
  }
}
