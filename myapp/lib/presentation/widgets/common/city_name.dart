import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/domain/entities/pk_city.dart';

/// The city's name in the app's language.
String cityName(AppLocalizations l10n, PkCity city) => switch (city.id) {
  'karachi' => l10n.cityKarachi,
  'lahore' => l10n.cityLahore,
  'islamabad' => l10n.cityIslamabad,
  'rawalpindi' => l10n.cityRawalpindi,
  'faisalabad' => l10n.cityFaisalabad,
  'multan' => l10n.cityMultan,
  'peshawar' => l10n.cityPeshawar,
  'quetta' => l10n.cityQuetta,
  'hyderabad' => l10n.cityHyderabad,
  'gujranwala' => l10n.cityGujranwala,
  'sialkot' => l10n.citySialkot,
  'bahawalpur' => l10n.cityBahawalpur,
  'sukkur' => l10n.citySukkur,
  'abbottabad' => l10n.cityAbbottabad,
  _ => city.id,
};
