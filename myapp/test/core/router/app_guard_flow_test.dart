// Covers: the router guard wired to the real providers: sign in -> consent -> quiz -> app
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/presentation/providers/app_router_provider.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';

void main() {
  testWidgets('the app opens step by step', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: SaafApp()));
    await tester.pump(const Duration(milliseconds: 400));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SaafApp)),
    );
    final router = container.read(appRouterProvider);

    Future<void> goTo(String path) async {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    bool on(String name) =>
        find.byKey(ValueKey('screen-$name')).evaluate().isNotEmpty;

    // Signed out: Home is closed.
    await goTo('/home');
    expect(on('welcome'), isTrue);

    // Signed in, no consent yet: the consent screen.
    container
        .read(authSessionControllerProvider.notifier)
        .set(const AuthSession(userId: 'u'));
    await tester.pump(const Duration(milliseconds: 400));
    await goTo('/home');
    expect(on('privacyConsent'), isTrue);

    // Consented, quiz not done: the quiz.
    container.read(consentStatusProvider.notifier).markGiven();
    await tester.pump(const Duration(milliseconds: 400));
    await goTo('/home');
    expect(on('skinQuiz'), isTrue);

    // Quiz done: the app is open.
    container.read(quizDoneProvider.notifier).markDone();
    await tester.pump(const Duration(milliseconds: 400));
    await goTo('/home');
    expect(on('home'), isTrue);

    // Signing out closes it again.
    container.read(authSessionControllerProvider.notifier).set(null);
    await tester.pump(const Duration(milliseconds: 400));
    expect(on('welcome'), isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
