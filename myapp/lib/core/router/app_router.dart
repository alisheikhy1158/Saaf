import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/router/app_guard.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/features/auth/screens/sign_up_screen.dart';
import 'package:saaf/presentation/features/auth/screens/verify_code_screen.dart';
import 'package:saaf/presentation/features/coach/screens/weekly_check_in_screen.dart';
import 'package:saaf/presentation/features/gallery/screens/gallery_screen.dart';
import 'package:saaf/presentation/features/home/screens/home_screen.dart';
import 'package:saaf/presentation/features/legal/screens/privacy_policy_screen.dart';
import 'package:saaf/presentation/features/legal/screens/terms_screen.dart';
import 'package:saaf/presentation/features/onboarding/screens/privacy_consent_screen.dart';
import 'package:saaf/presentation/features/onboarding/screens/skin_quiz_screen.dart';
import 'package:saaf/presentation/features/onboarding/screens/welcome_screen.dart';
import 'package:saaf/presentation/features/paywall/screens/paywall_screen.dart';
import 'package:saaf/presentation/features/products/screens/product_scan_result_screen.dart';
import 'package:saaf/presentation/features/profile/screens/profile_screen.dart';
import 'package:saaf/presentation/features/progress/screens/monthly_progress_screen.dart';
import 'package:saaf/presentation/features/routine/screens/routine_screen.dart';
import 'package:saaf/presentation/features/scan/screens/analysis_results_screen.dart';
import 'package:saaf/presentation/features/scan/screens/how_we_score_screen.dart';
import 'package:saaf/presentation/features/scan/screens/selfie_capture_screen.dart';
import 'package:saaf/presentation/widgets/common/not_found_screen.dart';

/// Which widget each route shows. Guards (auth, consent, paywall) join later.
Widget _screenFor(SaafRoute route, GoRouterState state) => switch (route.name) {
  'welcome' => const WelcomeScreen(),
  'signUp' => const SignUpScreen(),
  'verifyCode' => const VerifyCodeScreen(),
  'privacyConsent' => const PrivacyConsentScreen(),
  'skinQuiz' => const SkinQuizScreen(),
  'selfieCapture' => const SelfieCaptureScreen(),
  'analysisResults' => const AnalysisResultsScreen(),
  'routine' => const RoutineScreen(),
  'home' => const HomeScreen(),
  // The barcode comes from the address: /product-scan-result?barcode=…
  'productScanResult' => ProductScanResultScreen(
    barcode: state.uri.queryParameters['barcode'],
  ),
  'weeklyCheckIn' => const WeeklyCheckInScreen(),
  'monthlyProgress' => const MonthlyProgressScreen(),
  'paywall' => const PaywallScreen(),
  'profile' => const ProfileScreen(),
  _ => throw StateError('No screen registered for route ${route.name}'),
};

/// What the router guard needs to know right now.
class AppGuardState {
  const AppGuardState({
    required this.signedIn,
    required this.consented,
    required this.quizDone,
  });

  final bool signedIn;
  final bool? consented;
  final bool quizDone;
}

/// Builds the app's [GoRouter]. [initialLocation] is for tests.
/// The hidden `/gallery` route exists only when [enableGallery] (debug builds).
GoRouter buildAppRouter({
  String? initialLocation,
  bool? enableGallery,
  AppGuardState Function()? guard,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? SaafRoute.welcome.path,
    refreshListenable: refreshListenable,
    // Without a [guard] (tests) every page is open.
    redirect: guard == null
        ? null
        : (context, state) {
            final g = guard();
            return guardRedirect(
              path: state.uri.path,
              signedIn: g.signedIn,
              consented: g.consented,
              quizDone: g.quizDone,
            );
          },
    routes: [
      for (final route in SaafRoute.all)
        GoRoute(
          name: route.name,
          path: route.path,
          builder: (context, state) => _screenFor(route, state),
          routes: [
            // /skin-quiz is step 1; /skin-quiz/3 is step 3 (clamped to 1–5).
            if (route == SaafRoute.skinQuiz)
              GoRoute(
                path: ':step',
                builder: (context, state) => SkinQuizScreen(
                  step: int.tryParse(state.pathParameters['step'] ?? '') ?? 1,
                ),
              ),
          ],
        ),
      GoRoute(
        name: SaafRoute.howWeScore.name,
        path: SaafRoute.howWeScore.path,
        builder: (context, state) => const HowWeScoreScreen(),
      ),
      GoRoute(
        name: SaafRoute.terms.name,
        path: SaafRoute.terms.path,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        name: SaafRoute.privacyPolicy.name,
        path: SaafRoute.privacyPolicy.path,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      if (enableGallery ?? kDebugMode)
        GoRoute(
          name: SaafRoute.gallery.name,
          path: SaafRoute.gallery.path,
          builder: (context, state) => const GalleryScreen(),
        ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
