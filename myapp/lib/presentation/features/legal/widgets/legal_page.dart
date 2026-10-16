import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/legal/legal_documents.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// A legal document page: top bar with back, the document name (translated),
/// the date, then the English text in sections. While the documents are not
/// lawyer-reviewed a "draft" chip is shown, so a draft cannot ship unnoticed.
class LegalPage extends StatelessWidget {
  const LegalPage({
    required this.route,
    required this.title,
    required this.document,
    super.key,
  });

  final SaafRoute route;
  final String title;
  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return SaafScaffold(
      key: ValueKey('screen-${route.name}'),
      topBar: SaafTopBar.back(
        tooltip: l10n.back,
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(SaafRoute.welcome.path),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: tokens.styles.screenTitle),
          SizedBox(height: space.x8),
          Text(
            l10n.legalLastUpdated(document.lastUpdated),
            style: context.text.bodySmall,
          ),
          if (!LegalConfig.current.isReviewed) ...[
            SizedBox(height: space.x12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaafChip(
                label: l10n.legalDraftBanner,
                icon: Icons.edit_note,
                tone: SaafChipTone.papaya,
              ),
            ),
          ],
          if (!isEnglish) ...[
            SizedBox(height: space.x12),
            Text(l10n.legalEnglishOnlyNote, style: context.text.bodyMedium),
          ],
          SizedBox(height: space.sectionGapMedium),
          // The documents are English: keep them left-to-right and left-aligned.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(document.intro, style: context.text.bodyMedium),
                for (final section in document.sections)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: space.sectionGapMedium,
                    ),
                    child: _Section(section: section),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.space.x8,
      children: [
        Semantics(
          header: true,
          child: Text(section.heading, style: context.text.titleSmall),
        ),
        for (final paragraph in section.paragraphs)
          Text(paragraph, style: context.text.bodyMedium),
        for (final bullet in section.bullets)
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
    );
  }
}
