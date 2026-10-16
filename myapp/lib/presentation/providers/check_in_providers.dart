import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/in_memory_check_in_repository.dart';
import 'package:saaf/domain/repositories/check_in_repository.dart';

part 'check_in_providers.g.dart';

/// Swapped for the drift-backed repository in Phase 7.
@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) => InMemoryCheckInRepository();
