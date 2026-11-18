import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/presentation/providers/product_providers.dart';

/// Opens [url] in the phone's browser, and says so when it cannot (instead of
/// a button that seems to do nothing).
Future<void> openLink(BuildContext context, WidgetRef ref, String url) async {
  final result = await ref.read(externalLinkServiceProvider).open(url);
  if (result.isOk || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).productLinkFailed)),
  );
}
