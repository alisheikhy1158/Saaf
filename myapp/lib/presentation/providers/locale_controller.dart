import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/l10n/app_localizations.dart';

part 'locale_controller.g.dart';

/// The language the user chose, or null to follow the phone's language.
/// In memory only for now — persistence arrives with the local database.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) {
    if (locale != null &&
        !AppLocalizations.supportedLocales.contains(
          Locale(locale.languageCode),
        )) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported language');
    }
    state = locale;
  }
}
