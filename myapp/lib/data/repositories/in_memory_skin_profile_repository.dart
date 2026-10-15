import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';

/// Keeps the profile in memory. Placeholder until the drift database exists
/// (Phase 7); it is lost when the app closes.
class InMemorySkinProfileRepository implements SkinProfileRepository {
  SkinProfile? _profile;

  @override
  Future<SkinProfile?> current() async => _profile;

  @override
  Future<void> save(SkinProfile profile) async => _profile = profile;

  @override
  Future<void> clear() async => _profile = null;
}
