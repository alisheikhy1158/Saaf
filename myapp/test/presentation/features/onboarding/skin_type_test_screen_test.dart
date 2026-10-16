// Covers: the tissue test screen and how it feeds the "skin type" quiz step
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/presentation/features/onboarding/controllers/skin_quiz_controller.dart';
import 'package:saaf/domain/entities/quiz_step.dart';
import 'package:saaf/presentation/features/onboarding/screens/skin_type_test_screen.dart';

import '../../../helpers/pump_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Opens the test from the skin type step of the real app.
Future<void> _openFromQuiz(WidgetTester tester) async {
  await pumpSaafApp(tester, location: '/skin-quiz');
  await tester.pump();
  await _tap(tester, find.text('Not sure? Try the tissue test'));
}

void main() {
  group('the instructions come first', () {
    testWidgets('four steps, then "I\'ve done the test"', (tester) async {
      await _openFromQuiz(tester);
      expect(find.text('Tissue test'), findsOneWidget);
      expect(find.textContaining('Wash your face'), findsOneWidget);
      expect(find.textContaining('Wait about'), findsOneWidget);
      expect(find.textContaining('Press a clean tissue'), findsOneWidget);
      expect(find.textContaining('up to the light'), findsOneWidget);
      expect(find.text("I’ve done the test"), findsOneWidget);
      expect(find.text('Use this result'), findsNothing);
    });
  });

  group('what the tissue showed', () {
    Future<void> toQuestions(WidgetTester tester) async {
      await _openFromQuiz(tester);
      await _tap(tester, find.text("I’ve done the test"));
    }

    testWidgets('oil on the forehead and nose says combination', (
      tester,
    ) async {
      await toQuestions(tester);
      await _tap(tester, find.text('Oil mark from my forehead'));
      await _tap(tester, find.text('Oil mark from my nose'));
      expect(find.text('Your skin looks combination'), findsOneWidget);
      expect(
        find.textContaining('only on the forehead and nose'),
        findsOneWidget,
      );
    });

    testWidgets('oil on the cheeks as well says oily', (tester) async {
      await toQuestions(tester);
      await _tap(tester, find.text('Oil mark from my forehead'));
      await _tap(tester, find.text('Oil mark from my cheeks'));
      expect(find.text('Your skin looks oily'), findsOneWidget);
    });

    testWidgets('a clean tissue and tight skin says dry', (tester) async {
      await toQuestions(tester);
      await _tap(tester, find.text('My skin feels tight or flaky'));
      expect(find.text('Your skin looks dry'), findsOneWidget);
    });

    testWidgets('a clean tissue and comfortable skin says normal', (
      tester,
    ) async {
      await toQuestions(tester);
      expect(find.text('Your skin looks balanced'), findsOneWidget);
    });

    testWidgets('a result we cannot read asks to try again another day', (
      tester,
    ) async {
      await toQuestions(tester);
      await _tap(tester, find.text('Oil mark from my cheeks'));
      expect(find.textContaining('another day'), findsWidgets);
      expect(find.text('Use this result'), findsNothing);
    });

    testWidgets('says it is a guide and not a diagnosis', (tester) async {
      await toQuestions(tester);
      expect(find.textContaining('not a diagnosis'), findsOneWidget);
    });
  });

  group('using the result', () {
    testWidgets('selects that skin type on the quiz step', (tester) async {
      await _openFromQuiz(tester);
      await _tap(tester, find.text("I’ve done the test"));
      await _tap(tester, find.text('Oil mark from my forehead'));
      await _tap(tester, find.text('Oil mark from my nose'));
      await _tap(tester, find.text('Use this result'));

      expect(find.byType(SkinTypeTestScreen), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      expect(
        container.read(skinQuizControllerProvider(QuizStep.skinType)).selected,
        [SkinType.combination],
      );
    });

    testWidgets('Back leaves the quiz answer alone', (tester) async {
      await _openFromQuiz(tester);
      await _tap(tester, find.byTooltip('Back'));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      expect(
        container.read(skinQuizControllerProvider(QuizStep.skinType)).selected,
        isEmpty,
      );
    });
  });

  group('layout', () {
    testWidgets('is robust and accessible', (tester) async {
      await expectRobustLayout(
        tester,
        () => const SkinTypeTestScreen(),
        scaffold: false,
      );
      await pumpSaaf(tester, const SkinTypeTestScreen(), scaffold: false);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the questions step is robust too', (tester) async {
      for (final scale in [1.0, 2.0]) {
        await pumpSaaf(
          tester,
          const SkinTypeTestScreen(),
          scaffold: false,
          textScale: scale,
          locale: scale == 2.0 ? const Locale('ur') : const Locale('en'),
        );
        await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
