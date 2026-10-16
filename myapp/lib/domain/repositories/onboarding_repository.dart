/// Whether the user finished the skin quiz (the router guard keeps the app
/// closed until they did).
abstract interface class OnboardingRepository {
  Future<bool> quizDone();

  Future<void> setQuizDone({required bool done});
}
