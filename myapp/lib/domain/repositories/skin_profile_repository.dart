import 'package:saaf/domain/entities/skin_profile.dart';

/// Where the user's quiz answers are kept (local database, OFF-1).
abstract interface class SkinProfileRepository {
  Future<SkinProfile?> current();
  Future<void> save(SkinProfile profile);

  /// Forget the profile (logout / account deletion, SEC-7).
  Future<void> clear();
}
