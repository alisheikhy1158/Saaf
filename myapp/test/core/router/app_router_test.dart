// Covers: PLAN 2.5 (go_router with placeholder routes for the 14 screens),
// design.md §10 (screen inventory)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/app.dart';
import 'package:saaf/core/router/app_router.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/data/services/web/fake_permission_service.dart';
import 'package:saaf/domain/entities/camera_permission.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/app_router_provider.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';

void main() {
  group('route table', () {
    test('has exactly the 14 screens of design.md §10, numbered 01–14', () {
      expect(
        SaafRoute.all.map((r) => r.number),
        List.generate(14, (i) => i + 1),
      );
    });

    test('names and paths are unique, paths start with /', () {
      final names = SaafRoute.all.map((r) => r.name).toSet();
      final paths = SaafRoute.all.map((r) => r.path).toSet();
      expect(names.length, 14);
      expect(paths.length, 14);
      expect(SaafRoute.all.every((r) => r.path.startsWith('/')), isTrue);
    });

    test('matches the inventory order', () {
      expect(SaafRoute.all.map((r) => r.name).toList(), [
        'welcome',
        'signUp',
        'verifyCode',
        'privacyConsent',
        'skinQuiz',
        'selfieCapture',
        'analysisResults',
        'routine',
        'home',
        'productScanResult',
        'weeklyCheckIn',
        'monthlyProgress',
        'paywall',
        'profile',
      ]);
    });
  });

  group('router', () {
    for (final route in SaafRoute.all) {
      testWidgets('${route.path} shows screen ${route.number}', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appRouterProvider.overrideWithValue(
                buildAppRouter(initialLocation: route.path),
              ),
              // Verify code needs a number that is waiting for its code; without
              // one it sends the user back to Sign up (covered in its own test).
              pendingSignInProvider.overrideWithBuild(
                (ref, notifier) => PendingSignIn(
                  phone: PhoneNumber.parse('312 456 7890').valueOrNull!,
                  resendAfter: const Duration(seconds: 30),
                ),
              ),
              // The camera screen starts a camera and timers: use quiet fakes.
              permissionServiceProvider.overrideWithValue(
                FakePermissionService(CameraPermission.permanentlyDenied),
              ),
            ],
            child: const SaafApp(),
          ),
        );
        // Fixed pumps: a spinner on a screen would hang pumpAndSettle.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(ValueKey('screen-${route.name}')), findsOneWidget);
      });
    }

    testWidgets('starts on the Welcome screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: SaafApp()));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screen-welcome')), findsOneWidget);
    });

    testWidgets('an unknown path shows a friendly not-found page', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(
              buildAppRouter(initialLocation: '/does-not-exist'),
            ),
          ],
          child: const SaafApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('screen-not-found')), findsOneWidget);
    });
  });
}
