import 'package:saaf/core/utils/week.dart';
import 'package:saaf/domain/repositories/routine_log_repository.dart';

/// Keeps the log in memory (lost when the app closes). Replaced by the
/// drift-backed repository in Phase 7.
class InMemoryRoutineLogRepository implements RoutineLogRepository {
  final Map<DateTime, Set<String>> _done = {};

  @override
  Future<Set<String>> doneKeys(DateTime day) async =>
      Set.unmodifiable(_done[dateOnly(day)] ?? const <String>{});

  @override
  Future<void> setDone(DateTime day, String key, bool done) async {
    final keys = _done.putIfAbsent(dateOnly(day), () => <String>{});
    if (done) {
      keys.add(key);
    } else {
      keys.remove(key);
    }
  }
}
