import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/in_memory_routine_log_repository.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';

part 'home_providers.g.dart';

/// Swapped for the drift-backed log in Phase 7.
@Riverpod(keepAlive: true)
RoutineLogRepository routineLogRepository(Ref ref) =>
    InMemoryRoutineLogRepository();
