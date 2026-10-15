// Covers: design.md §9.6 (Terms/Privacy pages), store-compliance §1 (privacy
// policy reachable in-app). The real documents are published before release.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/presentation/features/legal/screens/privacy_policy_screen.dart';
import 'package:saaf/presentation/features/legal/screens/terms_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  test('the legal pages are routes outside the 14 Figma screens', () {
    expect(SaafRoute.all, isNot(contains(SaafRoute.terms)));
    expect(SaafRoute.all, isNot(contains(SaafRoute.privacyPolicy)));
    expect(SaafRoute.terms.path, '/terms');
    expect(SaafRoute.privacyPolicy.path, '/privacy-policy');
  });

  for (final (route, title, urduTitle, build)
      in <(SaafRoute, String, String, Widget Function())>[
        (
          SaafRoute.terms,
          'Terms of Use',
          'استعمال کی شرائط',
          () => const TermsScreen(),
        ),
        (
          SaafRoute.privacyPolicy,
          'Privacy Policy',
          'رازداری کی پالیسی',
          () => const PrivacyPolicyScreen(),
        ),
      ]) {
    group(route.name, () {
      testWidgets('shows its title and a back button', (tester) async {
        await pumpSaafApp(tester, location: route.path);
        expect(find.byKey(ValueKey('screen-${route.name}')), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
      });

      testWidgets('is translated and right-to-left in Urdu', (tester) async {
        await pumpSaaf(
          tester,
          build(),
          locale: const Locale('ur'),
          scaffold: false,
        );
        expect(find.text(urduTitle), findsOneWidget);
        final context = tester.element(find.text(urduTitle));
        expect(Directionality.of(context), TextDirection.rtl);
      });

      testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
        tester,
      ) async {
        await expectRobustLayout(tester, build, scaffold: false);
      });
    });
  }
}
