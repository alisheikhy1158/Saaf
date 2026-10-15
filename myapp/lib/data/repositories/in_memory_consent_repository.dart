import 'package:saaf/domain/entities/consent_record.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';

/// Keeps the consent in memory. Placeholder until the drift database exists
/// (Phase 7); it is lost when the app closes, so consent is asked again.
class InMemoryConsentRepository implements ConsentRepository {
  ConsentRecord? _record;

  @override
  Future<ConsentRecord?> current() async => _record;

  @override
  Future<void> save(ConsentRecord record) async => _record = record;

  @override
  Future<void> clear() async => _record = null;
}
