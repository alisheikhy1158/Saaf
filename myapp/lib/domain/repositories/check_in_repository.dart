import 'package:saaf/domain/entities/check_in.dart';

/// Where finished weekly check-ins are kept (on the phone; drift in Phase 7).
abstract interface class CheckInRepository {
  Future<void> save(CheckIn checkIn);

  /// Oldest first.
  Future<List<CheckIn>> all();
}
