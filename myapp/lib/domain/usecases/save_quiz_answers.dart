import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';

/// Saves the answer to one quiz step into the stored [SkinProfile], keeping what
/// the other steps saved.
class SaveQuizAnswers {
  const SaveQuizAnswers(this._repository);

  /// "Pick up to two" on the concerns step.
  static const int maxConcerns = 2;

  final SkinProfileRepository _repository;

  Future<Result<SkinProfile>> skinType(SkinType type) =>
      _update((p) => p.copyWith(skinType: type));

  Future<Result<SkinProfile>> concerns(Set<SkinConcern> concerns) async {
    if (concerns.isEmpty || concerns.length > maxConcerns) {
      return const Err(ValidationFailure('concerns'));
    }
    return _update((p) => p.copyWith(concerns: Set.unmodifiable(concerns)));
  }

  Future<Result<SkinProfile>> sensitivity(Sensitivity sensitivity) =>
      _update((p) => p.copyWith(sensitivity: sensitivity));

  /// An empty [flags] set means "none of these" and is saved as an answer.
  Future<Result<SkinProfile>> safety(Set<SafetyFlag> flags) =>
      _update((p) => p.copyWith(safetyFlags: Set.unmodifiable(flags)));

  Future<Result<SkinProfile>> budget(BudgetBand band) =>
      _update((p) => p.copyWith(budget: band));

  Future<Result<SkinProfile>> _update(
    SkinProfile Function(SkinProfile current) change,
  ) async {
    try {
      final current = await _repository.current() ?? const SkinProfile();
      final updated = change(current);
      await _repository.save(updated);
      return Ok(updated);
    } on Object {
      return const Err(StorageFailure());
    }
  }
}
