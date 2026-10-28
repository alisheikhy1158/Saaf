import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/repositories/settings_repository.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'settings_providers.g.dart';

/// Names under which settings are stored.
abstract final class SettingNames {
  static const reminders = 'reminders';
  static const language = 'language';
  static const theme = 'theme';
  static const name = 'name';
  static const age = 'age';

  /// The products the user uses now (JSON list of names).
  static const currentProducts = 'currentProducts';

  /// Saaf AI's last routine plan and what it was for (JSON).
  static const aiRoutinePlan = 'aiRoutinePlan';

  /// Which Saaf AI option the user chose for each routine step (JSON map).
  static const routineChoices = 'routineChoices';

  /// Saaf AI's skin estimates, by scan id (JSON).
  static const aiSkinEstimates = 'aiSkinEstimates';

  /// "on" / "off": the answer to "analyse every scan automatically?"; none
  /// until the user is asked.
  static const autoAnalyseScans = 'autoAnalyseScans';

  /// The city chosen for the skin weather (a `PkCity` id).
  static const weatherCity = 'weatherCity';

  /// The new product being introduced slowly (JSON).
  static const introduction = 'introduction';

  /// The event the user is getting ready for (JSON).
  static const lifeEvent = 'lifeEvent';

  /// "on" when Ramadan mode is on.
  static const ramadanMode = 'ramadanMode';

  /// "yes" once the user has read how voice input works.
  static const voiceExplained = 'voiceExplained';
}

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemorySettingsRepository()
      : DriftSettingsRepository(db);
}
