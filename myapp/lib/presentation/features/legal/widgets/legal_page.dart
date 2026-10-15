import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// A legal document page: top bar with back, the document name, its text.
/// The body is a placeholder until the real documents are published.
class LegalPage extends StatelessWidget {
  const LegalPage({required this.route, required this.title, super.key});

  final SaafRoute route;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

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
        spacing: tokens.space.titleToSubtitle,
        children: [
          Text(title, style: tokens.styles.screenTitle),
          Text(
            l10n.legalPlaceholderBody,
            style: context.text.bodyLarge?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
