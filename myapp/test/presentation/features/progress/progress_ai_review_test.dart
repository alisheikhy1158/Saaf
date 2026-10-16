// Covers: Progress every two weeks, and the AI progress review (the user chooses
// to send their first, previous and latest FRONT photos; asked first, with a
// preview, store-compliance §5)
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_message.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_coach_service.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/services/photo_shrinker.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';
import 'package:saaf/presentation/features/progress/screens/monthly_progress_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  _Clock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

class _Service implements AiCoachService {
  final List<({String question, int photos})> asked = [];

  @override
  Future<Result<String>> ask({
    required List<AiMessage> history,
    required String question,
    required List<Uint8List> photos,
    required AiContext context,
  }) async {
    asked.add((question: question, photos: photos.length));
    return const Ok('Your skin looks calmer; keep using sunscreen.');
  }

  @override
  Future<Result<void>> report({
    required AiMessage reply,
    required String reason,
  }) async => const Ok(null);
}

/// Keeps the photo as it is; can be told to fail for chosen photos.
class _Shrinker implements PhotoShrinker {
  _Shrinker({this.failAll = false});
  final bool failAll;

  @override
  Future<Uint8List?> shrink(Uint8List photo) async => failAll ? null : photo;
}

final _store = InMemoryPhotoStore();
late _Service _service;

Future<CompletedScan> _scan(String id, DateTime date, int shade) async {
  final photos = [
    for (final pose in FacePose.values)
      (await _store.save(
        scanId: id,
        pose: pose,
        bytes: solidPng(width: 8, height: 8, red: shade, green: 120, blue: 80),
      )).valueOrNull!,
  ];
  return CompletedScan(id: id, takenAt: date, photos: photos);
}

Progress _progress() => Progress(
  from: DateTime(2026, 10, 1),
  to: DateTime(2026, 10, 15),
  changes: const [
    Change(
      kind: SkinMetricKind.darkSpots,
      percent: -12,
      direction: ChangeDirection.better,
    ),
    Change(
      kind: SkinMetricKind.breakouts,
      percent: 0,
      direction: ChangeDirection.same,
    ),
    Change(
      kind: SkinMetricKind.oiliness,
      percent: 0,
      direction: ChangeDirection.same,
    ),
    Change(
      kind: SkinMetricKind.hydration,
      percent: 4,
      direction: ChangeDirection.better,
    ),
  ],
);

/// Three scans (first, previous, latest) unless [two] is set.
Future<ProgressView> _view({bool two = false}) async {
  final first = await _scan('first', DateTime(2026, 10, 1), 90);
  final latest = await _scan('latest', DateTime(2026, 10, 29), 110);
  if (two) {
    return ProgressView(
      progress: _progress(),
      before: first,
      after: latest,
      first: first,
    );
  }
  final previous = await _scan('previous', DateTime(2026, 10, 15), 100);
  return ProgressView(
    progress: _progress(),
    before: previous,
    after: latest,
    first: first,
  );
}

List<Override> _overrides({
  required ProgressView view,
  bool consented = true,
  bool pro = true,
  DateTime? now,
  PhotoShrinker? shrinker,
}) {
  final settings = InMemorySettingsRepository();
  if (consented) {
    settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 1).toIso8601String(),
    );
  }
  return [
    proStatusProvider.overrideWithBuild((ref, n) => pro),
    photoStoreProvider.overrideWithValue(_store),
    progressViewProvider.overrideWith((ref) => Future.value(view)),
    clockProvider.overrideWithValue(_Clock(now ?? DateTime(2026, 10, 30, 9))),
    aiCoachServiceProvider.overrideWithValue(_service),
    photoShrinkerProvider.overrideWithValue(shrinker ?? _Shrinker()),
    settingsRepositoryProvider.overrideWithValue(settings),
  ];
}

Future<void> _open(WidgetTester tester, List<Override> overrides) async {
  await pumpSaafApp(
    tester,
    location: '/monthly-progress',
    overrides: overrides,
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

ProviderContainer _container(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(MonthlyProgressScreen)),
);

void main() {
  setUp(() => _service = _Service());

  group('every two weeks', () {
    testWidgets('the label counts weeks since the first scan', (tester) async {
      await _open(tester, _overrides(view: await _view()));
      expect(find.text('WEEK 4'), findsOneWidget);
      expect(find.textContaining('MONTH'), findsNothing);
    });

    testWidgets('says how many days until the next scan', (tester) async {
      await _open(
        tester,
        _overrides(view: await _view(), now: DateTime(2026, 11, 5, 9)),
      );
      expect(find.text('Next scan in 7 days'), findsOneWidget);
    });

    testWidgets('when it is due, says so and offers to scan', (tester) async {
      await _open(
        tester,
        _overrides(view: await _view(), now: DateTime(2026, 11, 20)),
      );
      expect(find.text('Your 2-week scan is due'), findsOneWidget);
      await _tap(tester, find.text('Scan now'));
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
    });
  });

  group('the AI review card', () {
    testWidgets('is there for Pro users, with what it does', (tester) async {
      await _open(tester, _overrides(view: await _view()));
      expect(find.text('AI progress review'), findsOneWidget);
      expect(find.text('Review my progress with AI'), findsOneWidget);
    });

    testWidgets('free users only see the Pro message', (tester) async {
      await _open(tester, _overrides(view: await _view(), pro: false));
      expect(find.text('AI progress review'), findsNothing);
    });

    testWidgets('before agreeing it leads to the AI permission screen', (
      tester,
    ) async {
      await _open(tester, _overrides(view: await _view(), consented: false));
      expect(find.text('Set up the AI coach'), findsOneWidget);
      await _tap(tester, find.text('Set up the AI coach'));
      expect(find.text('Before you chat with the AI coach'), findsOneWidget);
      expect(_service.asked, isEmpty);
    });
  });

  group('sending the photos', () {
    testWidgets('shows exactly what will be sent and who gets it', (
      tester,
    ) async {
      await _open(tester, _overrides(view: await _view()));
      await _tap(tester, find.text('Review my progress with AI'));
      expect(find.text('Send these photos to the AI?'), findsOneWidget);
      expect(find.textContaining('Groq'), findsOneWidget);
      expect(
        find.textContaining('side photos stay on your phone'),
        findsOneWidget,
      );
      for (final i in [0, 1, 2]) {
        expect(find.byKey(ValueKey('review-photo-$i')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('review-photo-3')), findsNothing);
      expect(_service.asked, isEmpty, reason: 'nothing is sent before Send');
    });

    testWidgets('Cancel sends nothing', (tester) async {
      await _open(tester, _overrides(view: await _view()));
      await _tap(tester, find.text('Review my progress with AI'));
      await _tap(tester, find.text('Cancel'));
      expect(_service.asked, isEmpty);
      expect(find.byType(MonthlyProgressScreen), findsOneWidget);
    });

    testWidgets('Send puts the question in the AI chat and shows the answer', (
      tester,
    ) async {
      await _open(tester, _overrides(view: await _view()));
      await _tap(tester, find.text('Review my progress with AI'));
      await _tap(tester, find.text('Send'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(_service.asked, hasLength(1));
      expect(_service.asked.single.photos, 3);
      final question = _service.asked.single.question;
      expect(question, contains('compare my face photos'));
      expect(question, contains('Photo 1 is my first scan, taken 1 Oct'));
      expect(question, contains('Photo 2 was taken 15 Oct'));
      expect(question, contains('Photo 3 is my latest scan, taken 29 Oct'));
      expect(find.byKey(const ValueKey('screen-aiCoach')), findsOneWidget);
      expect(
        find.text('Your skin looks calmer; keep using sunscreen.'),
        findsOneWidget,
      );
      expect(find.text('AI answer'), findsOneWidget);
    });

    testWidgets('with only two scans, two photos are sent', (tester) async {
      await _open(tester, _overrides(view: await _view(two: true)));
      await _tap(tester, find.text('Review my progress with AI'));
      expect(find.byKey(const ValueKey('review-photo-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('review-photo-2')), findsNothing);
      await _tap(tester, find.text('Send'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(_service.asked.single.photos, 2);
      expect(
        _service.asked.single.question,
        contains('Photo 2 is my latest scan'),
      );
    });

    testWidgets('only the front photos are ever used', (tester) async {
      await _open(tester, _overrides(view: await _view()));
      final view = _container(tester).read(progressViewProvider).value!;
      for (final scan in [view.first, view.before, view.after]) {
        expect(frontPhotoOf(scan)!.pose, FacePose.front);
      }
    });

    testWidgets('photos that cannot be prepared say so and send nothing', (
      tester,
    ) async {
      await _open(
        tester,
        _overrides(view: await _view(), shrinker: _Shrinker(failAll: true)),
      );
      await _tap(tester, find.text('Review my progress with AI'));
      await _tap(tester, find.text('Send'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text('We couldn’t prepare your photos. Please try again.'),
        findsOneWidget,
      );
      expect(_service.asked, isEmpty);
      expect(find.byType(MonthlyProgressScreen), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('is robust with the new card', (tester) async {
      final view = await _view();
      for (final size in matrixSizes) {
        await pumpSaafApp(
          tester,
          location: '/monthly-progress',
          size: size,
          overrides: _overrides(view: view),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$size');
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}
