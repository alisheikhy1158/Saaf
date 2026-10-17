import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/domain/entities/product.dart';

/// "Morning" / "Night", or "After sehri" / "After iftar" in Ramadan mode.
String routineTimeName(
  AppLocalizations l10n,
  RoutineTime time, {
  required bool ramadan,
}) => switch ((time, ramadan)) {
  (RoutineTime.morning, false) => l10n.routineMorning,
  (RoutineTime.night, false) => l10n.routineNight,
  (RoutineTime.morning, true) => l10n.ramadanAfterSehri,
  (RoutineTime.night, true) => l10n.ramadanAfterIftar,
};
