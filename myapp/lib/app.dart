import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_theme.dart';
import 'package:saaf/presentation/providers/app_router_provider.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';

/// Root widget: Saaf themes (system light/dark/high-contrast), English + Urdu
/// localisation, go_router navigation.
class SaafApp extends ConsumerWidget {
  const SaafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authSessionSyncProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: SaafTheme.light(),
      darkTheme: SaafTheme.dark(),
      highContrastTheme: SaafTheme.highContrastLight(),
      highContrastDarkTheme: SaafTheme.highContrastDark(),
      themeMode: ThemeMode.system,
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
