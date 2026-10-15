import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Shown by the router for an unknown path.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const ValueKey('screen-not-found'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: context.saaf.space.gutter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: context.saaf.space.x12,
              children: [
                Text(
                  l10n.notFoundTitle,
                  style: context.text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  l10n.notFoundBody,
                  style: context.text.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => context.go(SaafRoute.welcome.path),
                  child: Text(l10n.goToStart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
