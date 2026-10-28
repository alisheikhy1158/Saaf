import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/repositories/onboarding_repository.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'onboarding_status.g.dart';

/// Whether the user has consented: null while it is being read from storage,
/// then true or false. The router guard keeps the app closed until it is true.
@Riverpod(keepAlive: true)
class ConsentStatus extends _$ConsentStatus {
  @override
  bool? build() {
    ref.watch(consentRepositoryProvider).current().then((record) {
      if (ref.mounted && state == null) state = record != null;
    });
    return null;
  }

  void markGiven() => state = true;
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null
      ? InMemoryOnboardingRepository()
      : DriftOnboardingRepository(db);
}

/// Whether the skin quiz was finished (or skipped to the end): null while it
/// is being read from storage. The router guard sends a new user to the quiz
/// until it is, and never redirects while it is still null. Remembered
/// between sessions.
@Riverpod(keepAlive: true)
class QuizDone extends _$QuizDone {
  @override
  bool? build() {
    ref.read(onboardingRepositoryProvider).quizDone().then((done) {
      if (ref.mounted && state == null) state = done;
    });
    return null;
  }

  void markDone() {
    state = true;
    ref.read(onboardingRepositoryProvider).setQuizDone(done: true);
  }
}
