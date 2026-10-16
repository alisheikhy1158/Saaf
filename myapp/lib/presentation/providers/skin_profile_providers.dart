import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/repositories/in_memory_skin_profile_repository.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';
import 'package:saaf/domain/usecases/save_quiz_answers.dart';

part 'skin_profile_providers.g.dart';

/// Swapped for the drift-backed repository in Phase 7.
@Riverpod(keepAlive: true)
SkinProfileRepository skinProfileRepository(Ref ref) =>
    InMemorySkinProfileRepository();

@riverpod
SaveQuizAnswers saveQuizAnswers(Ref ref) =>
    SaveQuizAnswers(ref.watch(skinProfileRepositoryProvider));

/// The quiz answers so far, for screens that need them synchronously (a quiz
/// step re-opens with its saved answer). Updated after each successful save.
@Riverpod(keepAlive: true)
class SkinProfileController extends _$SkinProfileController {
  @override
  SkinProfile build() => const SkinProfile();

  void set(SkinProfile profile) => state = profile;
}
