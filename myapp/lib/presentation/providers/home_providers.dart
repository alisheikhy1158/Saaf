import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_routine_log_repository.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'home_providers.g.dart';

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
RoutineLogRepository routineLogRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemoryRoutineLogRepository()
      : DriftRoutineLogRepository(db);
}
