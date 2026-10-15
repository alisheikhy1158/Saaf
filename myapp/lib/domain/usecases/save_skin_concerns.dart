import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';

/// Saves the concerns picked on the quiz: one or two ("Pick up to two").
class SaveSkinConcerns {
  const SaveSkinConcerns(this._repository);

  /// The most concerns a user may pick.
  static const int maxConcerns = 2;

  final SkinProfileRepository _repository;

  Future<Result<SkinProfile>> call(Set<SkinConcern> concerns) async {
    if (concerns.isEmpty || concerns.length > maxConcerns) {
      return const Err(ValidationFailure('concerns'));
    }
    final profile = SkinProfile(concerns: Set.unmodifiable(concerns));
    try {
      await _repository.save(profile);
    } on Object {
      return const Err(StorageFailure());
    }
    return Ok(profile);
  }
}
