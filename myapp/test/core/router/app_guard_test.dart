// Covers: PLAN Phase 5 router guard — no app access until signed in, consented
// and the quiz is done (store-compliance: consent before data is collected)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/router/app_guard.dart';

String? go(
  String path, {
  bool signedIn = true,
  bool? consented = true,
  bool quizDone = true,
}) => guardRedirect(
  path: path,
  signedIn: signedIn,
  consented: consented,
  quizDone: quizDone,
);

void main() {
  group('signed out', () {
    test('the sign-in pages and legal pages are open', () {
      for (final p in [
        '/welcome',
        '/sign-up',
        '/verify-code',
        '/terms',
        '/privacy-policy',
      ]) {
        expect(
          go(p, signedIn: false, consented: false, quizDone: false),
          isNull,
          reason: p,
        );
      }
    });

    test('everything else goes to Welcome', () {
      for (final p in [
        '/home',
        '/routine',
        '/profile',
        '/selfie-capture',
        '/paywall',
        '/privacy-consent',
        '/skin-quiz',
        '/skin-quiz/3',
      ]) {
        expect(go(p, signedIn: false), '/welcome', reason: p);
      }
    });
  });

  group('signed in, no consent yet', () {
    test('goes to the consent screen', () {
      expect(go('/home', consented: false), '/privacy-consent');
      expect(go('/skin-quiz', consented: false), '/privacy-consent');
    });

    test('the consent screen and the legal pages are open', () {
      for (final p in ['/privacy-consent', '/terms', '/privacy-policy']) {
        expect(go(p, consented: false, quizDone: false), isNull, reason: p);
      }
    });

    test('while the consent is still loading nothing is redirected away', () {
      expect(go('/home', consented: null, quizDone: false), isNull);
    });
  });

  group('consented, quiz not done', () {
    test('goes to the quiz', () {
      expect(go('/home', quizDone: false), '/skin-quiz');
      expect(go('/selfie-capture', quizDone: false), '/skin-quiz');
    });

    test('every quiz step and the legal pages are open', () {
      for (final p in [
        '/skin-quiz',
        '/skin-quiz/4',
        '/terms',
        '/privacy-policy',
      ]) {
        expect(go(p, quizDone: false), isNull, reason: p);
      }
    });
  });

  group('fully set up', () {
    test('the whole app is open', () {
      for (final p in [
        '/home',
        '/routine',
        '/profile',
        '/paywall',
        '/weekly-check-in',
        '/product-scan-result',
        '/how-we-score',
      ]) {
        expect(go(p), isNull, reason: p);
      }
    });

    test('the quiz and consent can be revisited (editing answers)', () {
      expect(go('/skin-quiz/5'), isNull);
      expect(go('/privacy-consent'), isNull);
    });

    test('the sign-in pages lead on to Home', () {
      for (final p in ['/welcome', '/sign-up', '/verify-code']) {
        expect(go(p), '/home', reason: p);
      }
    });
  });

  group('sign-in pages for someone part-way through', () {
    test('lead on to the next missing step', () {
      expect(go('/welcome', consented: false), '/privacy-consent');
      expect(go('/sign-up', quizDone: false), '/skin-quiz');
    });
  });
  group('the tissue test belongs to the skin quiz', () {
    test('is open while the quiz is not done yet', () {
      expect(go('/skin-type-test', quizDone: false), isNull);
    });

    test('is closed to people who have not consented', () {
      expect(go('/skin-type-test', consented: false), '/privacy-consent');
    });

    test('is closed when signed out', () {
      expect(go('/skin-type-test', signedIn: false), '/welcome');
    });
  });
}
