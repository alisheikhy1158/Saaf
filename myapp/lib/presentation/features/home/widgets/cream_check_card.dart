import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';

/// Home: a way into "Is this cream safe?".
class CreamCheckCard extends StatelessWidget {
  const CreamCheckCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                const ExcludeSemantics(
                  child: Icon(Icons.health_and_safety_outlined),
                ),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.creamHomeTitle,
                      style: tokens.styles.listTitle,
                    ),
                  ),
                ),
              ],
            ),
            Text(l10n.creamHomeBody, style: tokens.styles.pointCaption),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaafButton.text(
                label: l10n.creamHomeAction,
                onPressed: () => context.push(SaafRoute.creamCheck.path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
