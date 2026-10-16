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
}

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemorySettingsRepository()
      : DriftSettingsRepository(db);
}
