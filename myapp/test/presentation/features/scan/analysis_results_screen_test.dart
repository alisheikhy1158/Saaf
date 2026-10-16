// Covers: Figma 07 Analysis results (node 3:97), design.md §9 (empty / error
// states, "How we score" page), A11Y-1/2/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/presentation/features/scan/screens/analysis_results_screen.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';

import '../../../helpers/pump_app.dart';

/// The four bars of the Figma example: Dark spots 0.62, Breakouts 0.35,
/// Oiliness 0.55, Hydration 0.82 — a score of 76.
final _figma = SkinAnalysis(
  scanId: 'scan-1',
  takenAt: DateTime(2026, 10, 15, 9, 41),
  metrics: const [
    SkinMetric(kind: SkinMetricKind.darkSpots, amount: 0.62),
    SkinMetric(kind: SkinMetricKind.breakouts, amount: 0.35),
    SkinMetric(kind: SkinMetricKind.oiliness, amount: 0.55),
    SkinMetric(kind: SkinMetricKind.hydration, amount: 0.82),
  ],
);

List<Override> _with(SkinAnalysis? analysis, {FakeShareService? share}) => [
  skinAnalysisProvider.overrideWith((ref) async => analysis),
  shareServiceProvider.overrideWithValue(share ?? FakeShareService()),
];

Future<void> _open(
  WidgetTester tester, {
  SkinAnalysis? analysis,
  FakeShareService? share,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const AnalysisResultsScreen(),
    scaffold: false,
    size: size,
    overrides: _with(analysis, share: share),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('results', () {
    testWidgets('shows the date, the title, the score and the headline', (
      tester,
    ) async {
      await _open(tester, analysis: _figma);
      expect(find.text('SCAN · 15 OCT 2026'), findsOneWidget);
      expect(find.text('Here’s your skin today'), findsOneWidget);
      expect(find.text('76'), findsOneWidget);
      expect(find.text('Skin score'), findsOneWidget);
      expect(find.text('Good base, two things to work on'), findsOneWidget);
    });

    testWidgets('names the two focus areas', (tester) async {
      await _open(tester, analysis: _figma);
      expect(
        find.text('Dark spots and Oiliness are your main focus.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the four concern cards with their ratings', (
      tester,
    ) async {
      await _open(tester, analysis: _figma);
      expect(find.text('Concerns'), findsOneWidget);
      for (final (name, rating) in [
        ('Dark spots', 'Moderate'),
        ('Breakouts', 'Mild'),
        ('Oiliness', 'Moderate'),
        ('Hydration', 'Good'),
      ]) {
        expect(find.text(name), findsWidgets);
        expect(find.bySemanticsLabel('$name: $rating'), findsOneWidget);
      }
    });

    testWidgets('shows the disclaimer and the routine button', (tester) async {
      await _open(tester, analysis: _figma);
      expect(
        find.text(
          'A cosmetic screening, not a medical diagnosis. See a dermatologist '
          'for anything that worries you.',
        ),
        findsOneWidget,
      );
      expect(find.text('See my routine'), findsOneWidget);
    });

    testWidgets('the score ring says its value to screen readers', (
      tester,
    ) async {
      await _open(tester, analysis: _figma);
      expect(find.bySemanticsLabel('Skin score 76 out of 100'), findsOneWidget);
    });

    testWidgets('a worse skin gets a different headline', (tester) async {
      final worse = SkinAnalysis(
        scanId: 's',
        takenAt: _figma.takenAt,
        metrics: const [
          SkinMetric(kind: SkinMetricKind.darkSpots, amount: 0.9),
          SkinMetric(kind: SkinMetricKind.breakouts, amount: 0.9),
          SkinMetric(kind: SkinMetricKind.oiliness, amount: 0.9),
          SkinMetric(kind: SkinMetricKind.hydration, amount: 0.1),
        ],
      );
      await _open(tester, analysis: worse);
      expect(
        find.text('Your skin needs some care. Start with two things'),
        findsOneWidget,
      );
    });
  });

  group('share', () {
    testWidgets('shares the score as text, never photos', (tester) async {
      final share = FakeShareService();
      await _open(tester, analysis: _figma, share: share);
      await tester.tap(find.byTooltip('Share your result'));
      await tester.pump();
      expect(share.shared, hasLength(1));
      expect(share.shared.single, contains('76/100'));
      expect(share.shared.single, contains('Dark spots'));
      expect(share.shared.single, contains('Oiliness'));
    });
  });

  group('states', () {
    testWidgets('no scan yet: explains and offers to start one', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('No scan yet'), findsOneWidget);
      expect(find.text('Start a scan'), findsOneWidget);
      expect(find.text('76'), findsNothing);
    });

    testWidgets('a failed analysis can be retried', (tester) async {
      await pumpSaaf(
        tester,
        const AnalysisResultsScreen(),
        scaffold: false,
        overrides: [
          skinAnalysisProvider.overrideWith(
            (ref) async => throw const UnknownFailure('analyse'),
          ),
          shareServiceProvider.overrideWithValue(FakeShareService()),
        ],
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('We couldn’t read your results'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('while the analysis runs a spinner shows', (tester) async {
      await pumpSaaf(
        tester,
        const AnalysisResultsScreen(),
        scaffold: false,
        overrides: [
          skinAnalysisProvider.overrideWith(
            (ref) => Future<SkinAnalysis?>.delayed(
              const Duration(seconds: 30),
              () => _figma,
            ),
          ),
          shareServiceProvider.overrideWithValue(FakeShareService()),
        ],
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });
  });

  group('navigation', () {
    testWidgets('See my routine opens the routine', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/analysis-results',
        overrides: _with(_figma),
      );
      await tester.pump();
      await tester.ensureVisible(find.text('See my routine'));
      await tester.tap(find.text('See my routine'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-routine')), findsOneWidget);
    });

    testWidgets('How we score opens the explanation, back returns', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location: '/analysis-results',
        overrides: _with(_figma),
      );
      await tester.pump();
      await tester.tap(find.text('How we score'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-howWeScore')), findsOneWidget);
      expect(find.text('What we look at'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Here’s your skin today'), findsOneWidget);
    });

    testWidgets('Start a scan opens the camera screen', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/analysis-results',
        overrides: _with(null),
      );
      await tester.pump();
      await tester.tap(find.text('Start a scan'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the back button returns to the previous screen or home', (
      tester,
    ) async {
      await pumpSaafApp(
        tester,
        location: '/analysis-results',
        overrides: _with(_figma),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('results are robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const AnalysisResultsScreen(),
        scaffold: false,
        overrides: _with(_figma),
      );
      await _open(tester, analysis: _figma);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('empty state is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const AnalysisResultsScreen(),
        scaffold: false,
        overrides: _with(null),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });
  });
}
