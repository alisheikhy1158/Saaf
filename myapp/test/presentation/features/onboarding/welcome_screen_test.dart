// Covers: Figma 01 Welcome (node 2:15), design.md §9.5 (stat must be real or
// labelled "Example"), §9.1 (hit areas), A11Y-1/2/5/6/8, PLAN Phase 5
// (English/Urdu switch)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/features/onboarding/screens/welcome_screen.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_segmented_control.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('content (English)', () {
    testWidgets('shows the Figma copy', (tester) async {
      await pumpSaafApp(tester);
      expect(find.text('Saaf'), findsOneWidget);
      expect(find.text('For South Asian skin'), findsOneWidget);
      expect(find.text('Clear skin, made simple.'), findsOneWidget);
      expect(
        find.text(
          'A skincare coach for South Asian skin. Routines built from '
          'products you can actually buy in Pakistan.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('the hero stat is labelled as an example (§9.5)', (
      tester,
    ) async {
      await pumpSaafApp(tester);
      expect(find.textContaining('Example'), findsOneWidget);
      expect(find.text('−32% in 8 weeks'), findsOneWidget);
    });

    testWidgets('the hero is 350 × 372 on a 390 dp phone', (tester) async {
      await pumpSaafApp(tester);
      expect(
        tester.getSize(find.byKey(const ValueKey('welcome-hero'))),
        const Size(350, 372),
      );
    });

    testWidgets(
      'the stat card is compact and sits 20 dp from the hero corner',
      (tester) async {
        await pumpSaafApp(tester);
        final hero = tester.getRect(find.byKey(const ValueKey('welcome-hero')));
        final card = tester.getRect(
          find
              .ancestor(
                of: find.text('−32% in 8 weeks'),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        expect(card.height, lessThan(90), reason: 'a one-line caption + value');
        expect(card.left - hero.left, 20);
        expect(hero.bottom - card.bottom, 20);
      },
    );

    testWidgets('the hero art is bundled and hidden from screen readers', (
      tester,
    ) async {
      await pumpSaafApp(tester);
      final art = find.descendant(
        of: find.byKey(const ValueKey('welcome-hero')),
        matching: find.byType(Image),
      );
      expect(art, findsOneWidget);
      expect(
        find.ancestor(of: art, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
    });

    testWidgets('the title uses the 46 dp display style', (tester) async {
      await pumpSaafApp(tester);
      final title = tester.widget<Text>(find.text('Clear skin, made simple.'));
      expect(title.style?.fontSize, 46);
    });
  });

  group('language switch', () {
    testWidgets('starts on English', (tester) async {
      await pumpSaafApp(tester);
      final control = tester.widget<SaafSegmentedControl>(
        find.byType(SaafSegmentedControl),
      );
      expect(control.selectedIndex, 0);
    });

    testWidgets('choosing Urdu switches the whole app to Urdu, right-to-left', (
      tester,
    ) async {
      await pumpSaafApp(tester);
      await tester.tap(find.text('Urdu'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('شروع کریں'), findsOneWidget);
      final context = tester.element(find.byType(WelcomeScreen));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(
        tester
            .widget<SaafSegmentedControl>(find.byType(SaafSegmentedControl))
            .selectedIndex,
        1,
      );
    });

    testWidgets('choosing English again restores English, left-to-right', (
      tester,
    ) async {
      await pumpSaafApp(tester);
      await tester.tap(find.text('Urdu'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('English'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Get started'), findsOneWidget);
      final context = tester.element(find.byType(WelcomeScreen));
      expect(Directionality.of(context), TextDirection.ltr);
    });
  });

  group('navigation', () {
    testWidgets('Get started opens Sign up', (tester) async {
      await pumpSaafApp(tester);
      // (Under the 16 dp-wide Ahem test font the title wraps to 4 lines and
      // pushes the buttons below the fold, so scroll them into view first.)
      await tester.ensureVisible(find.text('Get started'));
      await tester.pump();
      await tester.tap(find.text('Get started'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });

    testWidgets('I already have an account opens Sign up', (tester) async {
      await pumpSaafApp(tester);
      await tester.ensureVisible(find.text('I already have an account'));
      await tester.pump();
      await tester.tap(find.text('I already have an account'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-signUp')), findsOneWidget);
    });
  });

  group('buttons', () {
    testWidgets('Get started is the 56 dp primary with a trailing arrow', (
      tester,
    ) async {
      await pumpSaafApp(tester);
      final primary = find.widgetWithText(FilledButton, 'Get started');
      expect(tester.getSize(primary).height, 56);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('the text button spans the width', (tester) async {
      await pumpSaafApp(tester);
      final text = find.widgetWithText(TextButton, 'I already have an account');
      expect(tester.getSize(text).width, 350);
      expect(
        tester.widget<SaafButton>(find.byType(SaafButton).last).variant,
        SaafButtonVariant.text,
      );
    });
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpSaafApp(tester);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const WelcomeScreen(),
      scaffold: false,
    );
  });

  testWidgets('renders on a 320 × 480 window with 200 % text', (tester) async {
    await pumpSaaf(
      tester,
      const WelcomeScreen(),
      size: const Size(320, 480),
      textScale: 2.0,
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
  });
}
