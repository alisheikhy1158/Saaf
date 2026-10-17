// Covers: Figma 05 Skin quiz (node 2:305, "STEP 2 OF 5") and the four steps
// designed around it (skin type, sensitivity, safety, budget), design.md §10
// (max-2 selection, "Skip" hit area), PLAN Phase 5, A11Y-1/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/budget_band.dart';
import 'package:saaf/domain/entities/safety_flag.dart';
import 'package:saaf/domain/entities/sensitivity.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/onboarding/screens/skin_quiz_screen.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_option_tile.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';

import '../../../domain/usecases/save_quiz_answers_test.dart'
    show FakeSkinProfileRepository;
import '../../../helpers/pump_app.dart';

/// What each step shows, in English.
class StepSpec {
  const StepSpec(this.step, this.title, this.hint, this.options);
  final int step;
  final String title;
  final String hint;

  /// (title, caption) of each option, in order.
  final List<(String, String)> options;
}

const _specs = [
  StepSpec(
    1,
    'How does your skin feel by midday?',
    'Pick the closest match. Not sure? That’s fine.',
    [
      ('Oily', 'Shiny, especially on the forehead and nose'),
      ('Dry', 'Tight or flaky, even after moisturiser'),
      ('Combination', 'Oily T-zone, drier cheeks'),
      ('Balanced', 'Comfortable, neither shiny nor tight'),
      ('Not sure', 'We’ll start gentle and learn with you'),
    ],
  ),
  StepSpec(
    2,
    'What bothers you most about your skin?',
    'Pick up to two. You can change this later.',
    [
      ('Dark spots & pigmentation', 'Marks left by acne or the sun'),
      ('Acne & breakouts', 'Pimples, blackheads, bumps'),
      ('Oiliness & large pores', 'Shiny by midday'),
      ('Dryness & dullness', 'Tight, flaky or tired-looking'),
      ('Uneven skin tone', 'Patchy colour, dark circles'),
    ],
  ),
  StepSpec(
    3,
    'How does your skin react to new products?',
    'Pick one. Strong ingredients stay away from sensitive skin.',
    [
      ('Rarely reacts', 'New products usually feel fine'),
      ('Sometimes reacts', 'Occasional stinging, redness or breakouts'),
      ('Often reacts', 'Many products sting or irritate'),
    ],
  ),
  StepSpec(
    4,
    'Anything we should keep in mind?',
    'Optional. This stays on your phone and only helps us avoid ingredients '
        'that may not suit you.',
    [
      (
        'Pregnant or breastfeeding',
        'We’ll leave out ingredients usually avoided',
      ),
      (
        'On a prescription skin treatment',
        'We’ll keep things gentle and suggest checking with your doctor',
      ),
      (
        'A known ingredient allergy',
        'For example fragrance or a specific ingredient',
      ),
      ('None of these', 'Nothing to add'),
    ],
  ),
  StepSpec(
    5,
    'What can you spend on skincare each month?',
    'Pick a range. Your routine is built from products that fit it.',
    [
      ('Under Rs 3,000', 'Simple, effective basics'),
      ('Rs 3,000 – 6,000', 'A solid routine with a few extras'),
      ('Rs 6,000 – 10,000', 'More choice, including treatments'),
      ('Over Rs 10,000', 'Anything that suits your skin'),
    ],
  ),
];

void main() {
  late FakeSkinProfileRepository repository;

  Future<void> pumpQuiz(
    WidgetTester tester, {
    String location = '/skin-quiz',
    Size size = const Size(390, 1500),
  }) async {
    repository = FakeSkinProfileRepository();
    await pumpSaafApp(
      tester,
      location: location,
      size: size,
      overrides: [skinProfileRepositoryProvider.overrideWithValue(repository)],
    );
  }

  Finder next() => find.descendant(
    of: find.byKey(const ValueKey('quiz-next')),
    matching: find.byType(FilledButton),
  );
  Finder skip() => find.widgetWithText(TextButton, 'Skip');

  Finder pageKey(int step) => find.byKey(
    ValueKey(step == 1 ? 'screen-skinQuiz' : 'screen-skinQuiz-$step'),
  );

  Set<String> selected(WidgetTester tester) => {
    for (final tile in tester.widgetList<SaafOptionTile>(
      find.byType(SaafOptionTile),
    ))
      if (tile.selected) tile.title,
  };

  Future<void> choose(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pump();
  }

  Future<void> pressNext(WidgetTester tester) async {
    await tester.tap(next());
    await tester.pump(const Duration(milliseconds: 600));
  }

  bool nextEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(next()).enabled;

  group('the five steps show their copy', () {
    for (final spec in _specs) {
      testWidgets('step ${spec.step}', (tester) async {
        await pumpQuiz(
          tester,
          location: spec.step == 1 ? '/skin-quiz' : '/skin-quiz/${spec.step}',
        );
        expect(find.text('STEP ${spec.step} OF 5'), findsOneWidget);
        expect(find.text(spec.title), findsOneWidget);
        expect(find.text(spec.hint), findsOneWidget);
        for (final (title, caption) in spec.options) {
          expect(find.text(title), findsOneWidget, reason: title);
          expect(find.text(caption), findsOneWidget, reason: caption);
        }
        expect(find.byType(SaafOptionTile), findsNWidgets(spec.options.length));
        expect(
          tester.widget<SaafProgressBar>(find.byType(SaafProgressBar)).value,
          closeTo(spec.step / 5, 0.001),
        );
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(skip(), findsOneWidget);
      });
    }

    testWidgets('the question uses the 29 dp headline style', (tester) async {
      await pumpQuiz(tester);
      final title = tester.widget<Text>(find.text(_specs[0].title));
      expect(title.style?.fontSize, 29);
    });

    testWidgets('a number outside 1–5 clamps; garbage means step 1', (
      tester,
    ) async {
      await pumpQuiz(tester, location: '/skin-quiz/9');
      expect(find.text('STEP 5 OF 5'), findsOneWidget);
      await pumpQuiz(tester, location: '/skin-quiz/abc');
      expect(find.text('STEP 1 OF 5'), findsOneWidget);
    });
  });

  group('every step needs an answer before Next', () {
    for (final spec in _specs) {
      testWidgets('step ${spec.step}', (tester) async {
        await pumpQuiz(
          tester,
          location: spec.step == 1 ? '/skin-quiz' : '/skin-quiz/${spec.step}',
        );
        expect(selected(tester), isEmpty);
        expect(nextEnabled(tester), isFalse);
        await choose(tester, spec.options.first.$1);
        expect(nextEnabled(tester), isTrue);
      });
    }
  });

  group('single choice (skin type, sensitivity, budget)', () {
    testWidgets('choosing another option replaces the first', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, 'Oily');
      await choose(tester, 'Dry');
      expect(selected(tester), {'Dry'});
    });

    testWidgets('tapping the chosen option keeps it chosen', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, 'Oily');
      await choose(tester, 'Oily');
      expect(selected(tester), {'Oily'});
    });
  });

  group('concerns (pick up to two)', () {
    testWidgets('two can be chosen, a third replaces the earliest', (
      tester,
    ) async {
      await pumpQuiz(tester, location: '/skin-quiz/2');
      await choose(tester, 'Dark spots & pigmentation');
      await choose(tester, 'Acne & breakouts');
      expect(selected(tester).length, 2);
      await choose(tester, 'Dryness & dullness');
      expect(selected(tester), {'Acne & breakouts', 'Dryness & dullness'});
    });

    testWidgets('tapping a chosen concern unchooses it', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/2');
      await choose(tester, 'Acne & breakouts');
      await choose(tester, 'Acne & breakouts');
      expect(selected(tester), isEmpty);
      expect(nextEnabled(tester), isFalse);
    });
  });

  group('safety (any combination, or none)', () {
    testWidgets('several flags can be chosen together', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/4');
      await choose(tester, 'Pregnant or breastfeeding');
      await choose(tester, 'A known ingredient allergy');
      expect(selected(tester), {
        'Pregnant or breastfeeding',
        'A known ingredient allergy',
      });
    });

    testWidgets('"None of these" clears the flags, and a flag clears it', (
      tester,
    ) async {
      await pumpQuiz(tester, location: '/skin-quiz/4');
      await choose(tester, 'Pregnant or breastfeeding');
      await choose(tester, 'None of these');
      expect(selected(tester), {'None of these'});
      await choose(tester, 'A known ingredient allergy');
      expect(selected(tester), {'A known ingredient allergy'});
    });

    testWidgets('"None of these" is a real answer: Next is enabled', (
      tester,
    ) async {
      await pumpQuiz(tester, location: '/skin-quiz/4');
      await choose(tester, 'None of these');
      expect(nextEnabled(tester), isTrue);
    });
  });

  group('saving', () {
    testWidgets('skin type', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, 'Combination');
      await pressNext(tester);
      expect(repository.saved?.skinType, SkinType.combination);
    });

    testWidgets('concerns', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/2');
      await choose(tester, 'Dark spots & pigmentation');
      await choose(tester, 'Acne & breakouts');
      await pressNext(tester);
      expect(repository.saved?.concerns, {
        SkinConcern.darkSpots,
        SkinConcern.acne,
      });
    });

    testWidgets('sensitivity', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/3');
      await choose(tester, 'Often reacts');
      await pressNext(tester);
      expect(repository.saved?.sensitivity, Sensitivity.high);
    });

    testWidgets('safety flags', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/4');
      await choose(tester, 'Pregnant or breastfeeding');
      await choose(tester, 'On a prescription skin treatment');
      await pressNext(tester);
      expect(repository.saved?.safetyFlags, {
        SafetyFlag.pregnantOrBreastfeeding,
        SafetyFlag.prescriptionTreatment,
      });
    });

    testWidgets('"None of these" saves an empty set, not null', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/4');
      await choose(tester, 'None of these');
      await pressNext(tester);
      expect(repository.saved?.safetyFlags, isNotNull);
      expect(repository.saved?.safetyFlags, isEmpty);
    });

    testWidgets('budget', (tester) async {
      await pumpQuiz(tester, location: '/skin-quiz/5');
      await choose(tester, 'Rs 3,000 – 6,000');
      await pressNext(tester);
      expect(repository.saved?.budget, BudgetBand.balanced);
    });

    testWidgets('each step keeps what the earlier ones saved', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, 'Oily');
      await pressNext(tester);
      await choose(tester, 'Acne & breakouts');
      await pressNext(tester);
      expect(repository.saved?.skinType, SkinType.oily);
      expect(repository.saved?.concerns, {SkinConcern.acne});
    });
  });

  group('navigation', () {
    testWidgets(
      'Next walks through the steps and ends on the products you use now',
      (tester) async {
        await pumpQuiz(tester);
        for (var step = 1; step <= 5; step++) {
          expect(find.text('STEP $step OF 5'), findsOneWidget);
          await choose(tester, _specs[step - 1].options.first.$1);
          await pressNext(tester);
        }
        // Then the selfie capture (see my_products_screen_test.dart).
        expect(find.byKey(const ValueKey('screen-myProducts')), findsOneWidget);
        expect(repository.saved?.budget, BudgetBand.essential);
      },
    );

    testWidgets('Skip moves on without saving', (tester) async {
      await pumpQuiz(tester);
      await tester.tap(skip());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('STEP 2 OF 5'), findsOneWidget);
      expect(repository.saveCalls, 0);
    });

    testWidgets('Skip on the last step opens the products you use now', (
      tester,
    ) async {
      await pumpQuiz(tester, location: '/skin-quiz/5');
      await tester.tap(skip());
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('screen-myProducts')), findsOneWidget);
    });

    testWidgets('Back on step 1 returns to the privacy consent', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        find.byKey(const ValueKey('screen-privacyConsent')),
        findsOneWidget,
      );
    });

    testWidgets('Back returns to the previous step with its answer kept', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await choose(tester, 'Combination');
      await pressNext(tester);
      expect(find.text('STEP 2 OF 5'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(pageKey(1), findsOneWidget);
      expect(selected(tester), {'Combination'});
    });

    testWidgets('a step opens with the answer saved earlier', (tester) async {
      await pumpQuiz(tester);
      await choose(tester, 'Dry');
      await pressNext(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      await choose(tester, 'Oily');
      await pressNext(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(selected(tester), {'Oily'});
    });
  });

  testWidgets('Urdu renders translated and right-to-left on every step', (
    tester,
  ) async {
    for (var step = 1; step <= 5; step++) {
      await pumpSaaf(
        tester,
        SkinQuizScreen(step: step),
        locale: const Locale('ur'),
        size: const Size(390, 1500),
        scaffold: false,
      );
      expect(tester.takeException(), isNull, reason: 'step $step');
      expect(find.text('Next'), findsNothing);
      expect(find.text(_specs[step - 1].title), findsNothing);
      expect(
        Directionality.of(tester.element(find.byType(SkinQuizScreen))),
        TextDirection.rtl,
      );
    }
  });

  testWidgets('passes the tap-target and label guidelines', (tester) async {
    await pumpQuiz(tester, location: '/skin-quiz/4');
    await expectTapTargetsAccessible(tester);
  });

  for (final step in [1, 4]) {
    testWidgets(
      'step $step survives the responsive / dark / 200 % / RTL matrix',
      (tester) async {
        await expectRobustLayout(
          tester,
          () => SkinQuizScreen(step: step),
          scaffold: false,
        );
      },
    );
  }
}
