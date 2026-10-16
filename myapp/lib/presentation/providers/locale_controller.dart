import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

part 'locale_controller.g.dart';

/// The language the user chose, or null to follow the phone's language.
/// In memory only for now — persistence arrives with the local database.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  bool _changed = false;

  @override
  Locale? build() {
    // The language chosen in an earlier session (the phone's language if none).
    ref.read(settingsRepositoryProvider).read(SettingNames.language).then((
      code,
    ) {
      final supported = AppLocalizations.supportedLocales
          .where((l) => l.languageCode == code)
          .firstOrNull;
      if (ref.mounted && !_changed && supported != null) state = supported;
    });
    return null;
  }

  void setLocale(Locale? locale) {
    if (locale != null &&
        !AppLocalizations.supportedLocales.contains(
          Locale(locale.languageCode),
        )) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported language');
    }
    _changed = true;
    state = locale;
    ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.language, locale?.languageCode);
  }
}
