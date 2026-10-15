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
