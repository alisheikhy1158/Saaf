// Covers: Figma 04 Privacy consent (node 2:227), store-compliance §1 (the
// promises on this screen are contractual; privacy policy linked in-app) and
// §2 (16+), PLAN Phase 5 (consent stored with timestamp + policy version),
// §9.1 (hit areas), A11Y-1/3/5/6/8
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/config/policy_version.dart';
import 'package:saaf/presentation/features/onboarding/screens/privacy_consent_screen.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_check_row.dart';

import '../../../domain/usecases/accept_consent_test.dart'
    show FakeClock, FakeConsentRepository;
import '../../../helpers/pump_app.dart';

/// Invokes the tap handler of the link span showing [text].
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

void main() {
  final now = DateTime.utc(2026, 10, 16, 9, 41);
  late FakeConsentRepository repository;

  Future<void> pumpConsent(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    repository = FakeConsentRepository();
    await pumpSaafApp(
      tester,
      location: '/privacy-consent',
      size: size,
      overrides: [
        consentRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FakeClock(now)),
      ],
    );
  }

  Finder agreeButton() =>
      find.widgetWithText(FilledButton, 'Agree and continue');

  Future<void> tick(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pump();
    await tester.tap(find.text(label));
    await tester.pump();
  }

  group('content (English)', () {
    testWidgets('shows the Figma copy', (tester) async {
      await pumpConsent(tester);
      expect(find.text('Your photos stay\non your phone'), findsOneWidget);
      expect(
        find.text(
          'Saaf checks your skin, not your identity. '
          'Here’s how we look after your data.',
        ),
        findsOneWidget,
      );
      for (final text in [
        'Saved on your device',
        'Your face-scan photos stay on your phone unless you turn on backup. The AI coach only gets a photo you choose to attach.',
        'Never sold or shared',
        'Brands and advertisers never see your face data.',
        'Delete anytime',
        'Remove your account and every photo in one tap.',
        'I am 16 or older',
        'Agree and continue',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('the title uses the 32 dp Figma screen-title style', (
      tester,
    ) async {
      await pumpConsent(tester);
      final title = tester.widget<Text>(
        find.text('Your photos stay\non your phone'),
      );
      expect(title.style?.fontSize, 32);
    });

    testWidgets('has a back button in the top bar', (tester) async {
      await pumpConsent(tester);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('the large shield sits in a 64 dp sage-tint circle', (
      tester,
    ) async {
      await pumpConsent(tester);
      expect(
        tester.getSize(find.byKey(const ValueKey('consent-shield'))),
        const Size(64, 64),
      );
    });
  });

  group('consent rules', () {
    testWidgets('both boxes start unticked and the button is disabled', (
      tester,
    ) async {
      await pumpConsent(tester);
      final rows = tester.widgetList<SaafCheckRow>(find.byType(SaafCheckRow));
      expect(rows.length, 2);
      expect(rows.every((r) => !r.value), isTrue);
      expect(tester.widget<FilledButton>(agreeButton()).enabled, isFalse);
    });

    testWidgets('one box is not enough', (tester) async {
      await pumpConsent(tester);
      await tick(tester, 'I am 16 or older');
      expect(tester.widget<FilledButton>(agreeButton()).enabled, isFalse);
    });

    testWidgets('both boxes enable the button; unticking disables it again', (
      tester,
    ) async {
      await pumpConsent(tester);
      await tick(tester, 'I am 16 or older');
      final terms = find.byKey(const ValueKey('consent-terms-row'));
      await tester.ensureVisible(terms);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('saaf-check-box')).first);
      await tester.pump();
      expect(tester.widget<FilledButton>(agreeButton()).enabled, isTrue);

      await tick(tester, 'I am 16 or older');
      expect(tester.widget<FilledButton>(agreeButton()).enabled, isFalse);
    });

    testWidgets('agreeing stores the consent and opens the skin quiz', (
      tester,
    ) async {
      await pumpConsent(tester);
      await tick(tester, 'I am 16 or older');
      await tester.tap(find.byKey(const ValueKey('saaf-check-box')).first);
      await tester.pump();

      await tester.ensureVisible(agreeButton());
      await tester.pump();
      await tester.tap(agreeButton());
      await tester.pump(const Duration(milliseconds: 600));

      expect(repository.saved?.acceptedAt, now);
      expect(repository.saved?.policyVersion, currentPolicyVersion);
      expect(find.byKey(const ValueKey('screen-skinQuiz')), findsOneWidget);
    });

    testWidgets('nothing is stored until the user agrees', (tester) async {
      await pumpConsent(tester);
      await tick(tester, 'I am 16 or older');
      expect(repository.saveCalls, 0);
    });
  });

  group('legal links (store requirement: policy linked in-app)', () {
    testWidgets('the agreement sentence contains Terms and Privacy links', (
      tester,
    ) async {
      await pumpConsent(tester);
      expect(tapLink(tester, 'Terms of Use'), isTrue);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-terms')), findsOneWidget);
    });

    testWidgets('the Privacy Policy link opens the policy page', (
      tester,
    ) async {
      await pumpConsent(tester);
      expect(tapLink(tester, 'Privacy Policy'), isTrue);
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyPolicy')),
        findsOneWidget,
      );
    });

    testWidgets('tapping a link does not tick the box', (tester) async {
      await pumpConsent(tester);
      tapLink(tester, 'Terms of Use');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      final first = tester.widgetList<SaafCheckRow>(find.byType(SaafCheckRow));
      expect(first.every((r) => !r.value), isTrue);
    });
  });

  group('Urdu', () {
    testWidgets('renders translated, right-to-left, without overflow', (
      tester,
    ) async {
      await pumpSaaf(
        tester,
        const PrivacyConsentScreen(),
        locale: const Locale('ur'),
        scaffold: false,
      );
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(PrivacyConsentScreen));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(find.text('Your photos stay\non your phone'), findsNothing);
    });
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpConsent(tester);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const PrivacyConsentScreen(),
      scaffold: false,
    );
  });

  testWidgets('fits a 320 × 480 window at 200 % text (scrolls)', (
    tester,
  ) async {
    await pumpSaaf(
      tester,
      const PrivacyConsentScreen(),
      size: const Size(320, 480),
      textScale: 2.0,
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SaafButton), findsWidgets);
  });
}
