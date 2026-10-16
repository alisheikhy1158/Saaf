// Covers: design.md §9.6 (Terms/Privacy pages), store-compliance §1 (privacy
// policy reachable in-app and complete), A11Y-1/6/8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/legal/legal_documents.dart';
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

  for (final (route, title, urduTitle, doc, build)
      in <(SaafRoute, String, String, LegalDocument, Widget Function())>[
        (
          SaafRoute.terms,
          'Terms of Use',
          'استعمال کی شرائط',
          LegalDocuments.terms(LegalConfig.current),
          () => const TermsScreen(),
        ),
        (
          SaafRoute.privacyPolicy,
          'Privacy Policy',
          'رازداری کی پالیسی',
          LegalDocuments.privacy(LegalConfig.current),
          () => const PrivacyPolicyScreen(),
        ),
      ]) {
    group(route.name, () {
      testWidgets('shows its title, back button and the draft banner', (
        tester,
      ) async {
        await pumpSaafApp(tester, location: route.path);
        expect(find.byKey(ValueKey('screen-${route.name}')), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(
          find.text('Draft: pending legal review'),
          findsOneWidget,
          reason: 'LegalConfig.current is not reviewed yet',
        );
      });

      testWidgets('shows the date, the intro and every section heading', (
        tester,
      ) async {
        await pumpSaafApp(
          tester,
          location: route.path,
          size: const Size(390, 6000),
        );
        expect(find.textContaining(doc.lastUpdated), findsOneWidget);
        expect(find.text(doc.intro), findsOneWidget);
        for (final section in doc.sections) {
          expect(
            find.text(section.heading),
            findsOneWidget,
            reason: section.heading,
          );
        }
      });

      testWidgets('shows paragraphs and bullet points', (tester) async {
        await pumpSaafApp(
          tester,
          location: route.path,
          size: const Size(390, 9000),
        );
        final withBullets = doc.sections.firstWhere(
          (s) => s.bullets.isNotEmpty,
        );
        expect(find.text(withBullets.bullets.first), findsOneWidget);
        final withText = doc.sections.firstWhere(
          (s) => s.paragraphs.isNotEmpty,
        );
        expect(find.text(withText.paragraphs.first), findsOneWidget);
      });

      testWidgets('is readable top to bottom on a small phone', (tester) async {
        await pumpSaaf(
          tester,
          build(),
          size: const Size(320, 568),
          scaffold: false,
        );
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -4000),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('in Urdu the chrome is translated and a note says the text '
          'is in English', (tester) async {
        await pumpSaaf(
          tester,
          build(),
          locale: const Locale('ur'),
          scaffold: false,
        );
        expect(find.text(urduTitle), findsOneWidget);
        expect(
          find.text('یہ دستاویز فی الحال صرف انگریزی میں دستیاب ہے۔'),
          findsOneWidget,
        );
        expect(
          Directionality.of(tester.element(find.text(urduTitle))),
          TextDirection.rtl,
        );
      });

      testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
        tester,
      ) async {
        await expectRobustLayout(tester, build, scaffold: false);
      });
    });
  }
}
