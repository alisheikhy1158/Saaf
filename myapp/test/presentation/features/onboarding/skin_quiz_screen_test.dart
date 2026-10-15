// Covers: Figma 05 Skin quiz (node 2:305), design.md §10 (max-2 selection,
// "Skip" hit area), PLAN Phase 5, A11Y-1/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/presentation/features/onboarding/screens/skin_quiz_screen.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';

import '../../../domain/usecases/save_skin_concerns_test.dart'
    show FakeSkinProfileRepository;
import '../../../helpers/pump_app.dart';

const _titles = {
  SkinConcern.darkSpots: 'Dark spots & pigmentation',
  SkinConcern.acne: 'Acne & breakouts',
  SkinConcern.oiliness: 'Oiliness & large pores',
  SkinConcern.dryness: 'Dryness & dullness',
  SkinConcern.unevenTone: 'Uneven skin tone',
};

void main() {
  late FakeSkinProfileRepository repository;

  Future<void> pumpQuiz(
    WidgetTester tester, {
    Size size = const Size(390, 1100),
  }) async {
    repository = FakeSkinProfileRepository();
    await pumpSaafApp(
      tester,
      location: '/skin-quiz',
      size: size,
      overrides: [skinProfileRepositoryProvider.overrideWithValue(repository)],
    );
  }

  Finder next() => find.widgetWithText(FilledButton, 'Next');

  Set<String> selectedTitles(WidgetTester tester) => {
    for (final tile in tester.widgetList<SaafOptionTile>(
      find.byType(SaafOptionTile),
    ))
      if (tile.selected) tile.title,
  };

  Future<void> choose(WidgetTester tester, SkinConcern concern) async {
    await tester.tap(find.text(_titles[concern]!));
    await tester.pump();
  }

  group('content (English)', () {
    testWidgets('shows the Figma copy', (tester) async {
      await pumpQuiz(tester);
      for (final text in [
        'STEP 2 OF 5',
        'What bothers you most about your skin?',
        'Pick up to two. You can change this later.',
        ..._titles.values,
        'Marks left by acne or the sun',
        'Pimples, blackheads, bumps',
        'Shiny by midday',
        'Tight, flaky or tired-looking',
        'Patchy colour, dark circles',
        'Skip',
        'Next',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('the question uses the 29 dp headline style', (tester) async {
      await pumpQuiz(tester);
      final title = tester.widget<Text>(
        find.text('What bothers you most about your skin?'),
      );
      expect(title.style?.fontSize, 29);
    });

    testWidgets('progress is step 2 of 5 = 40 %', (tester) async {
      await pumpQuiz(tester);
      expect(
        tester.widget<SaafProgressBar>(find.byType(SaafProgressBar)).value,
        closeTo(0.4, 0.001),
      );
    });

    testWidgets('has back, skip and next controls', (tester) async {
      await pumpQuiz(tester);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
      expect(next(), findsOneWidget);
    });
  });

  group('selection (pick up to two)', () {
    testWidgets('starts with nothing selected and Next disabled', (
      tester,
    ) async {
      await pumpQuiz(tester);
      expect(selectedTitles(tester), isEmpty);
      expect(tester.widget<FilledButton>(next()).enabled, isFalse);
    });

    testWidgets('selecting one enables Next', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, SkinConcern.acne);
      expect(selectedTitles(tester), {'Acne & breakouts'});
      expect(tester.widget<FilledButton>(next()).enabled, isTrue);
    });

    testWidgets('tapping a selected option unselects it', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, SkinConcern.acne);
      await choose(tester, SkinConcern.acne);
      expect(selectedTitles(tester), isEmpty);
      expect(tester.widget<FilledButton>(next()).enabled, isFalse);
    });

    testWidgets('two can be selected', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, SkinConcern.darkSpots);
      await choose(tester, SkinConcern.acne);
      expect(selectedTitles(tester), {
        'Dark spots & pigmentation',
        'Acne & breakouts',
      });
    });

    testWidgets('a third pick replaces the earliest one', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, SkinConcern.darkSpots);
      await choose(tester, SkinConcern.acne);
      await choose(tester, SkinConcern.dryness);
      expect(selectedTitles(tester), {
        'Acne & breakouts',
        'Dryness & dullness',
      });
    });
  });

  group('navigation', () {
    testWidgets('Next saves the picks and opens the selfie capture', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await choose(tester, SkinConcern.darkSpots);
      await choose(tester, SkinConcern.acne);
      await tester.tap(next());
      await tester.pump(const Duration(milliseconds: 600));

      expect(repository.saved?.concerns, {
        SkinConcern.darkSpots,
        SkinConcern.acne,
      });
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
    });

    testWidgets('Skip continues without saving anything', (tester) async {
      await pumpQuiz(tester);
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(repository.saveCalls, 0);
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
    });

    testWidgets('Back returns to the privacy consent screen', (tester) async {
      await pumpQuiz(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
    });
  });

  testWidgets('Urdu renders translated and right-to-left', (tester) async {
    await pumpSaaf(
      tester,
      const SkinQuizScreen(),
      locale: const Locale('ur'),
      size: const Size(390, 1100),
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Next'), findsNothing);
    final context = tester.element(find.byType(SkinQuizScreen));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpQuiz(tester);
    await expectTapTargetsAccessible(tester);
  });

  testWidgets('survives the responsive / dark / 200 % / RTL matrix', (
    tester,
  ) async {
    await expectRobustLayout(
      tester,
      () => const SkinQuizScreen(),
      scaffold: false,
    );
  });
}
