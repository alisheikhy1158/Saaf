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

  /// Saaf AI's skin estimates, by scan id (JSON).
  static const aiSkinEstimates = 'aiSkinEstimates';
}

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemorySettingsRepository()
      : DriftSettingsRepository(db);
}
