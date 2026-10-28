// Covers: Figma 03 Verify code (node 2:140), design.md §9.4 (OTP autofill path,
// keypad is not the only input), SEC-8 (6 digits), A11Y-1/4/5/6/8
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/presentation/features/auth/screens/verify_code_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';

import '../../../domain/usecases/auth_usecases_test.dart'
    show RecordingAuthRepository;
import '../../../helpers/pump_app.dart';

void main() {
  late RecordingAuthRepository repository;
  final phone = PhoneNumber.parse('312 456 7890').valueOrNull!;

  Future<void> pumpVerify(
    WidgetTester tester, {
    PendingSignIn? pending,
    Size size = const Size(390, 1100),
    bool returning = false,
  }) async {
    repository = RecordingAuthRepository();
    final signIn =
        pending ??
        PendingSignIn(phone: phone, resendAfter: const Duration(seconds: 30));
    await pumpSaafApp(
      tester,
      location: '/verify-code',
      size: size,
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        pendingSignInProvider.overrideWithBuild((ref, notifier) => signIn),
        // A returning user on this phone: already agreed, quiz done.
        if (returning) ...[
          consentStatusProvider.overrideWithBuild((ref, n) => true),
          quizDoneProvider.overrideWithBuild((ref, n) => true),
        ],
      ],
    );
  }

  Finder key(Object k) => find.byKey(ValueKey('saaf-key-$k'));
  Finder verify() => find.widgetWithText(FilledButton, 'Verify');

  Future<void> typeCode(WidgetTester tester, String code) async {
    for (final digit in code.split('')) {
      await tester.tap(key(digit));
      await tester.pump();
    }
  }

  group('content (English)', () {
    testWidgets('shows the Figma copy with the phone number and Edit', (
      tester,
    ) async {
      await pumpVerify(tester);
      expect(find.text('Enter the code'), findsOneWidget);
      expect(find.textContaining('Sent to +92 312 456 7890'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('starts with empty boxes and Verify disabled', (tester) async {
      await pumpVerify(tester);
      expect(tester.widget<FilledButton>(verify()).enabled, isFalse);
      expect(find.byKey(const ValueKey('saaf-otp-caret')), findsOneWidget);
    });

    testWidgets('shows the on-screen keypad', (tester) async {
      await pumpVerify(tester);
      for (var d = 0; d <= 9; d++) {
        expect(key(d), findsOneWidget);
      }
    });
  });

  group('entering the code', () {
    testWidgets('keypad digits fill the boxes', (tester) async {
      await pumpVerify(tester);
      await typeCode(tester, '4829');
      for (final d in ['4', '8', '2', '9']) {
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('verify-otp')),
            matching: find.text(d),
          ),
          findsOneWidget,
        );
      }
      expect(tester.widget<FilledButton>(verify()).enabled, isFalse);
    });

    testWidgets('the delete key removes the last digit', (tester) async {
      await pumpVerify(tester);
      await typeCode(tester, '482');
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('verify-otp')),
          matching: find.text('2'),
        ),
        findsNothing,
      );
    });

    testWidgets('delete on an empty code does nothing', (tester) async {
      await pumpVerify(tester);
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('six digits enable Verify and further keys are ignored', (
      tester,
    ) async {
      await pumpVerify(tester);
      await typeCode(tester, '482913');
      expect(tester.widget<FilledButton>(verify()).enabled, isTrue);
      await tester.tap(key(7));
      await tester.pump();
      await tester.tap(verify());
      await tester.pump(const Duration(milliseconds: 600));
      expect(repository.verified.single.$2, '482913');
    });

    testWidgets('the system keyboard / autofill / paste also work', (
      tester,
    ) async {
      await pumpVerify(tester);
      await tester.enterText(find.byType(TextField), '482913');
      await tester.pump();
      expect(tester.widget<FilledButton>(verify()).enabled, isTrue);
    });
  });

  group('verifying', () {
    testWidgets('a correct code signs in and opens the privacy consent', (
      tester,
    ) async {
      await pumpVerify(tester);
      await typeCode(tester, '482913');
      await tester.tap(verify());
      await tester.pump(const Duration(milliseconds: 600));

      expect(repository.verified.single.$1.e164, '+923124567890');
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
    });

    testWidgets(
      '"I already have an account": straight to Home, no onboarding',
      (tester) async {
        await pumpVerify(tester, returning: true);
        await typeCode(tester, '482913');
        await tester.tap(verify());
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
      },
    );

    testWidgets('a wrong code shows an error and stays on the page', (
      tester,
    ) async {
      await pumpVerify(tester);
      repository.verifyResult = const Err(ValidationFailure('code'));
      await typeCode(tester, '000000');
      await tester.tap(verify());
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text('That code doesn’t match. Check it and try again.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('screen-privacyConsent')), findsNothing);
    });

    testWidgets('typing again clears the error', (tester) async {
      await pumpVerify(tester);
      repository.verifyResult = const Err(ValidationFailure('code'));
      await typeCode(tester, '000000');
      await tester.tap(verify());
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(
        find.text('That code doesn’t match. Check it and try again.'),
        findsNothing,
      );
    });

    testWidgets('a network failure shows its own message', (tester) async {
      await pumpVerify(tester);
      repository.verifyResult = const Err(NetworkFailure());
      await typeCode(tester, '482913');
      await tester.tap(verify());
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.text(
          'We couldn’t verify the code. Check your connection and try again.',
        ),
        findsOneWidget,
      );
    });
  });

  group('resend', () {
    testWidgets('counts down from the resend delay', (tester) async {
      await pumpVerify(tester);
      expect(find.text('Resend code in 0:30'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend code in 0:29'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Resend code in 0:24'), findsOneWidget);
    });

    testWidgets('when it reaches zero a Resend button replaces the timer', (
      tester,
    ) async {
      await pumpVerify(tester);
      await tester.pump(const Duration(seconds: 30));
      expect(find.textContaining('Resend code in'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Resend code'), findsOneWidget);
    });

    testWidgets('Resend asks for a new code and restarts the countdown', (
      tester,
    ) async {
      await pumpVerify(tester);
      await tester.pump(const Duration(seconds: 30));
      await tester.tap(find.widgetWithText(TextButton, 'Resend code'));
      await tester.pump();
      await tester.pump();

      expect(repository.requested.single.e164, '+923124567890');
      expect(find.text('Resend code in 0:30'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('Edit returns to Sign up', (tester) async {
      await pumpVerify(tester);
      bool visit(InlineSpan span) {
        if (span is TextSpan) {
          if (span.text == 'Edit' && span.recognizer is TapGestureRecognizer) {
            (span.recognizer! as TapGestureRecognizer).onTap!();
            return true;
          }
          return (span.children ?? const []).any(visit);
        }
        return false;
      }

      final tapped = tester
          .widgetList<RichText>(find.byType(RichText))
          .any((rich) => visit(rich.text));
      expect(tapped, isTrue);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });

    testWidgets('Back returns to Sign up', (tester) async {
      await pumpVerify(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });

    testWidgets('an automatic sign-in (Android) moves on without typing', (
      tester,
    ) async {
      await pumpVerify(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(VerifyCodeScreen)),
      );
      container
          .read(authSessionControllerProvider.notifier)
          .set(const AuthSession(userId: 'auto-1'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
    });

    testWidgets('without a pending sign-in it redirects to Sign up', (
      tester,
    ) async {
      repository = RecordingAuthRepository();
      await pumpSaafApp(
        tester,
        location: '/verify-code',
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });
  });

  testWidgets('Urdu renders right-to-left with Western digits', (tester) async {
    await pumpSaaf(
      tester,
      const VerifyCodeScreen(),
      locale: const Locale('ur'),
      size: const Size(390, 1100),
      scaffold: false,
      overrides: [
        pendingSignInProvider.overrideWithBuild(
          (ref, notifier) => PendingSignIn(
            phone: phone,
            resendAfter: const Duration(seconds: 30),
          ),
        ),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Verify'), findsNothing);
    expect(find.byKey(const ValueKey('saaf-key-1')), findsOneWidget);
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpVerify(tester);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const VerifyCodeScreen(),
      scaffold: false,
      overrides: [
        pendingSignInProvider.overrideWithBuild(
          (ref, notifier) => PendingSignIn(
            phone: phone,
            resendAfter: const Duration(seconds: 30),
          ),
        ),
      ],
    );
  });
}
