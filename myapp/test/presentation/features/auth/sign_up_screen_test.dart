// Covers: Figma 02 Sign up (node 2:76), design.md §9.3 (Sign in with Apple on iOS
// only, real legal links), store-compliance A-2, SEC-8, A11Y-1/5/6/8
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/presentation/features/auth/screens/sign_up_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';

import '../../../domain/usecases/auth_usecases_test.dart'
    show RecordingAuthRepository;
import '../../../helpers/pump_app.dart';

void main() {
  late RecordingAuthRepository repository;

  Future<void> pumpSignUp(
    WidgetTester tester, {
    Size size = const Size(390, 1100),
    TargetPlatform? platform,
    bool returning = false,
  }) async {
    repository = RecordingAuthRepository();
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await pumpSaafApp(
      tester,
      location: '/sign-up',
      size: size,
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        // A returning user on this phone: already agreed, quiz done.
        if (returning) ...[
          consentStatusProvider.overrideWithBuild((ref, n) => true),
          quizDoneProvider.overrideWithBuild((ref, n) => true),
        ],
      ],
    );
  }

  Finder phoneField() => find.byType(TextField);
  Finder sendCode() => find.widgetWithText(FilledButton, 'Send code');

  Future<void> enterPhone(WidgetTester tester, String text) async {
    await tester.enterText(phoneField(), text);
    await tester.pump();
  }

  bool tapLink(WidgetTester tester, String text) {
    bool visit(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text == text && span.recognizer is TapGestureRecognizer) {
          (span.recognizer! as TapGestureRecognizer).onTap!();
          return true;
        }
        return (span.children ?? const []).any(visit);
      }
      return false;
    }

    return tester
        .widgetList<RichText>(find.byType(RichText))
        .any((rich) => visit(rich.text));
  }

  group('content (English)', () {
    testWidgets('shows the Figma copy', (tester) async {
      await pumpSignUp(tester);
      for (final text in [
        'Let’s get you started',
        'Use your mobile number. No passwords to remember.',
        'Mobile number',
        '+92',
        'We’ll text you a 6-digit code.',
        'Send code',
        'or',
        'Continue with Google',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('the title uses the 34 dp headline style', (tester) async {
      await pumpSaafApp(tester, location: '/sign-up');
      final title = tester.widget<Text>(find.text('Let’s get you started'));
      expect(title.style?.fontSize, 34);
    });

    testWidgets('the legal sentence links to Terms and Privacy', (
      tester,
    ) async {
      await pumpSignUp(tester);
      expect(tapLink(tester, 'Terms of Use'), isTrue);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-terms')), findsOneWidget);
    });

    testWidgets('the Privacy Policy link opens the policy', (tester) async {
      await pumpSignUp(tester);
      expect(tapLink(tester, 'Privacy Policy'), isTrue);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyPolicy')),
        findsOneWidget,
      );
    });
  });

  group('phone field', () {
    testWidgets('starts empty: no check, Send code disabled', (tester) async {
      await pumpSignUp(tester);
      expect(find.byKey(const ValueKey('saaf-field-valid')), findsNothing);
      expect(tester.widget<FilledButton>(sendCode()).enabled, isFalse);
    });

    testWidgets('formats the number as it is typed', (tester) async {
      await pumpSignUp(tester);
      await enterPhone(tester, '3124567890');
      expect(find.text('312 456 7890'), findsOneWidget);
    });

    testWidgets(
      'a complete number shows the sage check and enables the button',
      (tester) async {
        await pumpSignUp(tester);
        await enterPhone(tester, '312 456 7890');
        expect(find.byKey(const ValueKey('saaf-field-valid')), findsOneWidget);
        expect(tester.widget<FilledButton>(sendCode()).enabled, isTrue);
      },
    );

    testWidgets('an incomplete number keeps everything off', (tester) async {
      await pumpSignUp(tester);
      await enterPhone(tester, '312 456 789');
      expect(find.byKey(const ValueKey('saaf-field-valid')), findsNothing);
      expect(tester.widget<FilledButton>(sendCode()).enabled, isFalse);
    });

    testWidgets('an invalid prefix (landline) is not accepted', (tester) async {
      await pumpSignUp(tester);
      await enterPhone(tester, '212 456 7890');
      expect(tester.widget<FilledButton>(sendCode()).enabled, isFalse);
    });

    testWidgets('uses the phone keyboard', (tester) async {
      await pumpSignUp(tester);
      expect(
        tester.widget<TextField>(phoneField()).keyboardType,
        TextInputType.phone,
      );
    });
  });

  group('sending the code', () {
    testWidgets('requests the code and opens Verify code', (tester) async {
      await pumpSignUp(tester);
      await enterPhone(tester, '312 456 7890');
      await tester.tap(sendCode());
      await tester.pump(const Duration(milliseconds: 600));

      expect(repository.requested.single.e164, '+923124567890');
      expect(find.byKey(const ValueKey('screen-verifyCode')), findsOneWidget);
    });

    testWidgets('a network failure shows a message and stays on the page', (
      tester,
    ) async {
      await pumpSignUp(tester);
      repository.requestResult = const Err(NetworkFailure());
      await enterPhone(tester, '312 456 7890');
      await tester.tap(sendCode());
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text(
          'We couldn’t send the code. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('screen-verifyCode')), findsNothing);
    });

    testWidgets('editing the number clears the error', (tester) async {
      await pumpSignUp(tester);
      repository.requestResult = const Err(NetworkFailure());
      await enterPhone(tester, '312 456 7890');
      await tester.tap(sendCode());
      await tester.pump(const Duration(milliseconds: 600));
      await enterPhone(tester, '312 456 789');
      expect(
        find.text(
          'We couldn’t send the code. Check your connection and try again.',
        ),
        findsNothing,
      );
    });
  });

  group('social sign-in', () {
    testWidgets('Google signs in and continues to the privacy consent', (
      tester,
    ) async {
      await pumpSignUp(tester);
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
    });

    testWidgets('a failed Google sign-in shows a message', (tester) async {
      await pumpSignUp(tester);
      repository.verifyResult = const Err(NetworkFailure());
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.text('We couldn’t sign you in. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('Android offers "Continue with Apple" too', (tester) async {
      await pumpSignUp(tester, platform: TargetPlatform.android);
      expect(find.text('Continue with Apple'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a returning user signing in with Google goes to Home', (
      tester,
    ) async {
      await pumpSignUp(tester, returning: true);
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });

    testWidgets('closing the Google window is not an error', (tester) async {
      await pumpSignUp(tester);
      repository.verifyResult = const Err(SignInCancelled());
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.text('We couldn’t sign you in. Please try again.'),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });

    testWidgets('iOS shows "Continue with Apple" above Google (§9.3)', (
      tester,
    ) async {
      await pumpSignUp(tester, platform: TargetPlatform.iOS);
      final apple = tester.getRect(find.text('Continue with Apple'));
      final google = tester.getRect(find.text('Continue with Google'));
      expect(apple.top, lessThan(google.top));
      // Same outline button as Google, with equal prominence.
      expect(
        find.widgetWithText(OutlinedButton, 'Continue with Apple'),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(find.widgetWithText(OutlinedButton, 'Continue with Apple'))
            .width,
        tester
            .getSize(
              find.widgetWithText(OutlinedButton, 'Continue with Google'),
            )
            .width,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Apple signs in and continues to the privacy consent', (
      tester,
    ) async {
      await pumpSignUp(tester, platform: TargetPlatform.iOS);
      await tester.tap(find.text('Continue with Apple'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('Back returns to Welcome', (tester) async {
    await pumpSignUp(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('screen-welcome')), findsOneWidget);
  });

  testWidgets('Urdu renders translated and right-to-left', (tester) async {
    await pumpSaaf(
      tester,
      const SignUpScreen(),
      locale: const Locale('ur'),
      size: const Size(390, 1100),
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Send code'), findsNothing);
    expect(
      Directionality.of(tester.element(find.byType(SignUpScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpSignUp(tester);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SignUpScreen(),
      scaffold: false,
    );
  });
}
