import 'package:saaf/domain/entities/product.dart';

/// Which routine steps were done on which day (the Home checklist). Works
/// offline; the local database stores it in Phase 7.
abstract interface class RoutineLogRepository {
  /// The keys (see [routineStepKey]) of the steps done on [day].
  Future<Set<String>> doneKeys(DateTime day);

  Future<void> setDone(DateTime day, String key, bool done);
}

/// Identifies one step of the routine: the same product used in the morning and
/// at night is two steps.
String routineStepKey(RoutineTime time, Product product) =>
    '${time.name}:${product.id}';
