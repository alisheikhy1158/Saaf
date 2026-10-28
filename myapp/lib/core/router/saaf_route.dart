import 'package:flutter/foundation.dart';

/// One of the 14 Figma screens (docs/design.md §10).
@immutable
class SaafRoute {
  const SaafRoute._(this.number, this.name, this.path, this.title);

  /// Figma screen number, 1–14.
  final int number;

  /// go_router route name.
  final String name;
  final String path;

  /// English dev label, used only by placeholder screens.
  final String title;

  static const welcome = SaafRoute._(1, 'welcome', '/welcome', 'Welcome');
  static const signUp = SaafRoute._(2, 'signUp', '/sign-up', 'Sign up');
  static const verifyCode = SaafRoute._(
    3,
    'verifyCode',
    '/verify-code',
    'Verify code',
  );
  static const privacyConsent = SaafRoute._(
    4,
    'privacyConsent',
    '/privacy-consent',
    'Privacy consent',
  );
  static const skinQuiz = SaafRoute._(5, 'skinQuiz', '/skin-quiz', 'Skin quiz');
  static const selfieCapture = SaafRoute._(
    6,
    'selfieCapture',
    '/selfie-capture',
    'Selfie capture',
  );
  static const analysisResults = SaafRoute._(
    7,
    'analysisResults',
    '/analysis-results',
    'Analysis results',
  );
  static const routine = SaafRoute._(8, 'routine', '/routine', 'Routine');
  static const home = SaafRoute._(9, 'home', '/home', 'Home');
  static const productScanResult = SaafRoute._(
    10,
    'productScanResult',
    '/product-scan-result',
    'Product scan result',
  );
  static const weeklyCheckIn = SaafRoute._(
    11,
    'weeklyCheckIn',
    '/weekly-check-in',
    'Weekly check-in',
  );
  static const monthlyProgress = SaafRoute._(
    12,
    'monthlyProgress',
    '/monthly-progress',
    'Monthly progress',
  );
  static const paywall = SaafRoute._(13, 'paywall', '/paywall', 'Saaf Pro');
  static const profile = SaafRoute._(
    14,
    'profile',
    '/profile',
    'Profile & privacy',
  );

  /// Dev-only widget gallery (PLAN 2.6). Not a Figma screen, so not in [all];
  /// the router registers it only in debug builds.
  static const gallery = SaafRoute._(0, 'gallery', '/gallery', 'Gallery');

  /// Legal pages reachable from the consent screen, sign-up, paywall and
  /// profile (store requirement). Not Figma screens, so not in [all].
  static const terms = SaafRoute._(0, 'terms', '/terms', 'Terms of Use');
  static const privacyPolicy = SaafRoute._(
    0,
    'privacyPolicy',
    '/privacy-policy',
    'Privacy Policy',
  );

  /// The AI skin coach, opened from Home. Not a Figma screen, so not in [all].
  static const aiCoach = SaafRoute._(0, 'aiCoach', '/ai-coach', 'AI coach');

  /// The AI coach's consent screen, going back to where it was opened from
  /// once the user agrees (so what they were doing carries on).
  static const aiConsentAndReturn = '/ai-coach?return=1';

  /// Scan a product's barcode (or type it), opened from Home. Not a Figma
  /// screen, so not in [all].
  static const scanProduct = SaafRoute._(
    0,
    'scanProduct',
    '/scan-product',
    'Scan a product',
  );

  /// Look a product up with Saaf AI (unknown barcode, a QR link or a label
  /// photo), opened from the product scan. Not a Figma screen, so not in [all].
  static const productAi = SaafRoute._(
    0,
    'productAi',
    '/product-ai',
    'Saaf AI look-up',
  );

  /// The products the user uses now: after the skin quiz (?setup=1) and from
  /// Profile. Not a Figma screen, so not in [all].
  static const myProducts = SaafRoute._(
    0,
    'myProducts',
    '/my-products',
    'Products you use now',
  );

  /// "Is this cream safe?", from Home and the product scan. Not a Figma
  /// screen, so not in [all].
  static const creamCheck = SaafRoute._(
    0,
    'creamCheck',
    '/cream-check',
    'Is this cream safe?',
  );

  /// The tissue test for the skin type, opened from the skin quiz (step 1). Not
  /// a Figma screen, so not in [all].
  static const skinTypeTest = SaafRoute._(
    0,
    'skinTypeTest',
    '/skin-type-test',
    'Skin type test',
  );

  /// "How we score", opened from the results screen (07). Not a Figma screen,
  /// so not in [all].
  static const howWeScore = SaafRoute._(
    0,
    'howWeScore',
    '/how-we-score',
    'How we score',
  );

  /// In Figma order.
  static const List<SaafRoute> all = [
    welcome,
    signUp,
    verifyCode,
    privacyConsent,
    skinQuiz,
    selfieCapture,
    analysisResults,
    routine,
    home,
    productScanResult,
    weeklyCheckIn,
    monthlyProgress,
    paywall,
    profile,
  ];
}
