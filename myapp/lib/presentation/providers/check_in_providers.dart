import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_check_in_repository.dart';
import 'package:saaf/domain/repositories/check_in_repository.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'check_in_providers.g.dart';

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null ? InMemoryCheckInRepository() : DriftCheckInRepository(db);
}
