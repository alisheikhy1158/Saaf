/// Where a visitor may go: the router guard as one pure function.
///
/// Order of steps: sign in, consent, skin quiz. Until a step is done every
/// other page redirects to it. [consented] is null while it is still being
/// read from the database: nothing is redirected away then (a brief wait is
/// better than bouncing a user who already consented). [quizDone] is null the
/// same way.
String? guardRedirect({
  required String path,
  required bool signedIn,
  required bool? consented,
  required bool? quizDone,
}) {
  const signInPages = {'/welcome', '/sign-up', '/verify-code'};
  const legalPages = {'/terms', '/privacy-policy'};
  // The tissue test is part of the skin quiz.
  final isQuiz =
      path == '/skin-quiz' ||
      path.startsWith('/skin-quiz/') ||
      path == '/skin-type-test';

  if (!signedIn) {
    return signInPages.contains(path) || legalPages.contains(path)
        ? null
        : '/welcome';
  }

  if (consented == false) {
    final open = path == '/privacy-consent' || legalPages.contains(path);
    if (!open) return '/privacy-consent';
    return null;
  }

  if (consented == true && quizDone == false) {
    final open = isQuiz || legalPages.contains(path);
    if (!open) return '/skin-quiz';
    return null;
  }

  // Signed in and set up: the sign-in pages have nothing left to do.
  if (signInPages.contains(path)) return '/home';
  return null;
}
