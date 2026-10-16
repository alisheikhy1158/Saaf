import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/router/app_router.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';

part 'app_router_provider.g.dart';

/// The app's router with the guard on: signed in, then consent, then the quiz.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Bumped whenever something the guard looks at changes, so the router re-checks.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authSessionControllerProvider, (_, _) => refresh.value++)
    ..listen(consentStatusProvider, (_, _) => refresh.value++)
    ..listen(quizDoneProvider, (_, _) => refresh.value++);

  final router = buildAppRouter(
    refreshListenable: refresh,
    guard: () => AppGuardState(
      signedIn: ref.read(authSessionControllerProvider) != null,
      consented: ref.read(consentStatusProvider),
      quizDone: ref.read(quizDoneProvider),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}
