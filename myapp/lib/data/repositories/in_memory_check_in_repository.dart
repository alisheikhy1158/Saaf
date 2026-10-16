import 'package:saaf/domain/entities/check_in.dart';
import 'package:saaf/domain/repositories/check_in_repository.dart';

/// Keeps check-ins in memory (lost when the app closes). Replaced by the
/// drift-backed repository in Phase 7.
class InMemoryCheckInRepository implements CheckInRepository {
  final List<CheckIn> _items = [];

  @override
  Future<void> save(CheckIn checkIn) async => _items.add(checkIn);

  @override
  Future<List<CheckIn>> all() async => List.unmodifiable(_items);
}
