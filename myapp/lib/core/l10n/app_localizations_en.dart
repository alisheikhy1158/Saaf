// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Saaf';

  @override
  String get welcomeTitle => 'Clear skin, made simple.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'We couldn\'t find that page.';

  @override
  String get goToStart => 'Go to start';
}
