// Covers: Figma 11 Weekly check-in (node 3:537): coach chat with quick replies, a
// result card, a reply field; rule-based, no AI (store-compliance §5), A11Y-1/2/3/5/6/8
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_check_in_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/coach/screens/weekly_check_in_screen.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/check_in_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

/// Thursday 15 October: week 3 for a first scan on 1 October.
final _now = DateTime(2026, 10, 15, 9, 41);

List<Override> _with({
  bool scan = true,
  String? name = 'Ayesha Khan',
  InMemoryCheckInRepository? repository,
}) => [
  clockProvider.overrideWithValue(_Clock(_now)),
  checkInRepositoryProvider.overrideWithValue(
    repository ?? InMemoryCheckInRepository(),
  ),
  completedScanProvider.overrideWithBuild(
    (ref, n) => scan
        ? CompletedScan(
            id: 's',
            takenAt: DateTime(2026, 10, 1),
            photos: const [],
          )
        : null,
  ),
  authSessionControllerProvider.overrideWithBuild(
    (ref, n) =>
        name == null ? null : AuthSession(userId: 'u', displayName: name),
  ),
];

Future<void> _open(
  WidgetTester tester, {
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const WeeklyCheckInScreen(),
    scaffold: false,
    size: size,
    overrides: overrides ?? _with(),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pump();
  await tester.pump();
}

void main() {
  group('opening', () {
    testWidgets('shows the title, the week and the coach question', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Weekly check-in'), findsOneWidget);
      expect(find.text('Week 3 of your routine'), findsOneWidget);
      expect(
        find.text('Salam Ayesha! How has your skin felt this week?'),
        findsOneWidget,
      );
    });

    testWidgets('without a name the greeting has none', (tester) async {
      await _open(tester, overrides: _with(name: null));
      expect(
        find.text('Salam! How has your skin felt this week?'),
        findsOneWidget,
      );
    });

    testWidgets('offers four quick replies and a reply field', (tester) async {
      await _open(tester);
      for (final reply in [
        'Less oily than before',
        'About the same',
        'Drier or tighter',
        'More irritated',
      ]) {
        expect(find.text(reply), findsOneWidget, reason: reply);
      }
      expect(find.text('Reply in English or Urdu…'), findsOneWidget);
      expect(find.byTooltip('Send'), findsOneWidget);
    });

    testWidgets('the coach avatar shows an S', (tester) async {
      await _open(tester);
      expect(find.text('S'), findsOneWidget);
    });
  });

  group('the conversation', () {
    testWidgets('a quick reply becomes a message and the coach asks again', (
      tester,
    ) async {
      await _open(tester);
      await _tapText(tester, 'Less oily than before');
      // The reply stays in the chat; the first set of replies is gone.
      expect(find.text('Less oily than before'), findsOneWidget);
      expect(find.text('About the same'), findsNothing);
      expect(
        find.text('Nice. Any new breakouts since last week?'),
        findsOneWidget,
      );
      expect(find.text('1–2 small ones'), findsOneWidget);
    });

    testWidgets('the coach answers each reply in its own way', (tester) async {
      await _open(tester);
      await _tapText(tester, 'More irritated');
      expect(
        find.text('Sorry to hear that. Any new breakouts since last week?'),
        findsOneWidget,
      );
    });

    testWidgets('the second answer shows the result card', (tester) async {
      await _open(tester);
      await _tapText(tester, 'Less oily than before');
      await _tapText(tester, '1–2 small ones');
      expect(find.text('Likely on track'), findsOneWidget);
      expect(
        find.text(
          'Oil control is improving. A few small breakouts are common in '
          'week 3. Keep going and try not to pick.',
        ),
        findsOneWidget,
      );
      expect(find.text('Next photo check · 31 Oct'), findsOneWidget);
    });

    testWidgets('no quick replies are left once it is done', (tester) async {
      await _open(tester);
      await _tapText(tester, 'About the same');
      await _tapText(tester, 'No new ones');
      expect(find.text('No new ones'), findsOneWidget); // only the chat bubble
      expect(find.text('1–2 small ones'), findsNothing);
    });

    testWidgets('painful breakouts send the user to a professional', (
      tester,
    ) async {
      await _open(tester);
      await _tapText(tester, 'About the same');
      await _tapText(tester, 'Many or painful');
      expect(find.text('Please check with a professional'), findsOneWidget);
      expect(
        find.textContaining('dermatologist or pharmacist'),
        findsOneWidget,
      );
      expect(find.text('Likely on track'), findsNothing);
    });

    testWidgets('no scan yet: no invented photo date', (tester) async {
      await _open(tester, overrides: _with(scan: false));
      await _tapText(tester, 'About the same');
      await _tapText(tester, 'No new ones');
      expect(find.textContaining('Next photo check'), findsNothing);
    });

    testWidgets('the result is saved on the phone', (tester) async {
      final repository = InMemoryCheckInRepository();
      await _open(tester, overrides: _with(repository: repository));
      await _tapText(tester, 'Less oily than before');
      await _tapText(tester, '1–2 small ones');
      expect(await repository.all(), hasLength(1));
    });

    testWidgets('the result card is read as one block', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);
      await _tapText(tester, 'Less oily than before');
      await _tapText(tester, '1–2 small ones');
      expect(
        find.bySemanticsLabel(RegExp('^Result: Likely on track')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('typing', () {
    testWidgets('a typed reply answers the open question', (tester) async {
      await _open(tester);
      await tester.enterText(
        find.byType(TextField),
        'a bit tight on my cheeks',
      );
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      await tester.pump();
      expect(find.text('a bit tight on my cheeks'), findsOneWidget);
      expect(
        find.text('Thanks. Any new breakouts since last week?'),
        findsOneWidget,
      );
      // The field is emptied for the next reply.
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    });

    testWidgets('an empty reply is not sent', (tester) async {
      await _open(tester);
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      expect(find.text('Less oily than before'), findsOneWidget);
      expect(
        find.text('Salam Ayesha! How has your skin felt this week?'),
        findsOneWidget,
      );
    });

    testWidgets('the keyboard send key sends too', (tester) async {
      await _open(tester);
      await tester.enterText(find.byType(TextField), 'ok');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('a note after the result is saved and acknowledged', (
      tester,
    ) async {
      await _open(tester);
      await _tapText(tester, 'About the same');
      await _tapText(tester, 'No new ones');
      await tester.enterText(find.byType(TextField), 'chin is better');
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Thanks, I’ve saved your note for your next check-in.'),
        findsOneWidget,
      );
    });
  });

  group('info and navigation', () {
    testWidgets('the info button explains that no AI is used', (tester) async {
      await _open(tester);
      await tester.tap(find.byTooltip('About check-ins'));
      await tester.pumpAndSettle();
      expect(find.text('About check-ins'), findsWidgets);
      expect(find.textContaining('not AI'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not AI'), findsNothing);
    });

    testWidgets('back goes Home when opened directly', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/weekly-check-in',
        overrides: _with(),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-home')), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('the start is robust and accessible', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const WeeklyCheckInScreen(),
        scaffold: false,
        overrides: _with(),
      );
      await _open(tester);
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the finished check-in is robust and accessible', (
      tester,
    ) async {
      await expectRobustLayoutSettled(
        tester,
        () => const WeeklyCheckInScreen(),
        scaffold: false,
        overrides: _with(),
        after: () async {
          // The quick replies are the only buttons inside the Wrap, whatever
          // the language: the second one, then the first one.
          for (final index in [1, 0]) {
            final reply = find
                .descendant(
                  of: find.byType(Wrap),
                  matching: find.byType(InkWell),
                )
                .at(index);
            await tester.ensureVisible(reply);
            await tester.tap(reply, warnIfMissed: false);
            await tester.pump();
            await tester.pump();
          }
        },
      );
      await _open(tester);
      await _tapText(tester, 'About the same');
      await _tapText(tester, 'No new ones');
      await expectTapTargetsAccessible(tester);
    });
  });
}
