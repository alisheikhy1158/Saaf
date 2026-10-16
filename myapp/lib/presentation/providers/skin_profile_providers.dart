import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_skin_profile_repository.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/repositories/skin_profile_repository.dart';
import 'package:saaf/domain/usecases/save_quiz_answers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'skin_profile_providers.g.dart';

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
SkinProfileRepository skinProfileRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemorySkinProfileRepository()
      : DriftSkinProfileRepository(db);
}

@riverpod
SaveQuizAnswers saveQuizAnswers(Ref ref) =>
    SaveQuizAnswers(ref.watch(skinProfileRepositoryProvider));

/// The quiz answers so far, for screens that need them synchronously (a quiz
/// step re-opens with its saved answer). Updated after each successful save.
@Riverpod(keepAlive: true)
class SkinProfileController extends _$SkinProfileController {
  @override
  SkinProfile build() {
    // Answers saved in an earlier session. A change made meanwhile wins.
    ref.read(skinProfileRepositoryProvider).current().then((saved) {
      if (ref.mounted && saved != null && state == const SkinProfile()) {
        state = saved;
      }
    });
    return const SkinProfile();
  }

  void set(SkinProfile profile) => state = profile;
}
