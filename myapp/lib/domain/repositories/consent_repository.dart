import 'package:saaf/domain/entities/consent_record.dart';

/// Where the user's consent is kept (local database; source of truth, OFF-1).
abstract interface class ConsentRepository {
  Future<ConsentRecord?> current();
  Future<void> save(ConsentRecord record);

  /// Forget the consent (logout / account deletion, SEC-7).
  Future<void> clear();
}
