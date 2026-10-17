// Covers: Figma 12 Progress (every two weeks; was Monthly progress) (node 3:613): Pro gate, before / after
// slider, two change cards, coach summary; design.md §9 (empty / error states),
// PRV-2 (photos are never shared), A11Y-1/2/3/5/6/8
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/services/photo_shrinker.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/compare_progress.dart';
import 'package:saaf/presentation/features/progress/screens/monthly_progress_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';

import '../../../helpers/pump_app.dart';

final _store = InMemoryPhotoStore();
final _share = FakeShareService();

Future<CompletedScan> _scan(String id, DateTime date) async {
  final photos = [
    for (final pose in FacePose.values)
      (await _store.save(
        scanId: id,
        pose: pose,
        bytes: solidPng(width: 8, height: 8, red: 90, green: 120, blue: 80),
      )).valueOrNull!,
  ];
  return CompletedScan(id: id, takenAt: date, photos: photos);
}

Progress _progress({
  int spots = -18,
  int hydration = 6,
  ChangeDirection spotsDirection = ChangeDirection.better,
}) => Progress(
  from: DateTime(2026, 9, 14),
  to: DateTime(2026, 10, 14),
  changes: [
    Change(
      kind: SkinMetricKind.darkSpots,
      percent: spots,
      direction: spotsDirection,
    ),
    const Change(
      kind: SkinMetricKind.breakouts,
      percent: 0,
      direction: ChangeDirection.same,
    ),
    const Change(
      kind: SkinMetricKind.oiliness,
      percent: 0,
      direction: ChangeDirection.same,
    ),
    Change(
      kind: SkinMetricKind.hydration,
      percent: hydration,
      direction: hydration > 0 ? ChangeDirection.better : ChangeDirection.same,
    ),
  ],
);

Future<ProgressView> _view({Progress? progress, bool analysed = true}) async {
  final before = await _scan('before', DateTime(2026, 9, 14));
  final after = await _scan('after', DateTime(2026, 10, 14));
  return ProgressView(
    progress: analysed ? progress ?? _progress() : null,
    before: before,
    after: after,
    first: before,
  );
}

List<Override> _with({
  bool pro = true,
  ProgressView? view,
  Future<ProgressView?> Function()? load,
}) => [
  proStatusProvider.overrideWithBuild((ref, n) => pro),
  photoStoreProvider.overrideWithValue(_store),
  shareServiceProvider.overrideWithValue(_share),
  progressViewProvider.overrideWith(
    (ref) => load != null ? load() : Future.value(view),
  ),
];

Future<void> _open(
  WidgetTester tester, {
  List<Override>? overrides,
  Size size = const Size(390, 844),
}) async {
  await pumpSaaf(
    tester,
    const MonthlyProgressScreen(),
    scaffold: false,
    size: size,
    overrides: overrides ?? const [],
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pump();
  await tester.pump();
}

class _SkinService implements AiSkinService {
  int calls = 0;

  @override
  Future<Result<AiSkinEstimate>> estimateSkin({
    required Uint8List photo,
    required String languageCode,
  }) async {
    calls++;
    return const Ok(AiSkinEstimate(usable: false, problem: 'Too dark.'));
  }
}

class _Shrinker implements PhotoShrinker {
  @override
  Future<Uint8List?> shrink(Uint8List photo) async => photo;
}

void main() {
  setUp(() {
    _share.shared.clear();
    _share.files.clear();
  });

  group('before & after animation', () {
    testWidgets('is made from the photos and shared only on a tap', (
      tester,
    ) async {
      await _open(tester, overrides: _with(view: await _view()));
      expect(_share.files, isEmpty);
      await tester.ensureVisible(find.text('Share before & after'));
      await tester.tap(find.text('Share before & after'));
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
      }
      expect(_share.files, hasLength(1));
      expect(_share.files.single.mimeType, 'image/gif');
      expect(_share.files.single.bytes, isNotEmpty);
    });
  });

  group('scans not analysed by Saaf AI yet', () {
    late _SkinService skin;
    setUp(() => skin = _SkinService());

    Future<List<Override>> unanalysed() async {
      final settings = InMemorySettingsRepository();
      await settings.write(
        AiConsent.settingName,
        DateTime(2026, 10, 17).toIso8601String(),
      );
      return [
        ..._with(view: await _view(analysed: false)),
        settingsRepositoryProvider.overrideWithValue(settings),
        aiSkinServiceProvider.overrideWithValue(skin),
        photoShrinkerProvider.overrideWithValue(_Shrinker()),
      ];
    }

    testWidgets('shows the photos but no numbers, never a guess', (
      tester,
    ) async {
      await _open(tester, overrides: await unanalysed());
      expect(find.text('Your progress'), findsOneWidget);
      expect(find.text('Skin measures not analysed yet'), findsOneWidget);
      expect(find.text('Analyse with Saaf AI'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.byTooltip('Share your progress'), findsNothing);
    });

    testWidgets('asks first, then sends the front photo of each scan', (
      tester,
    ) async {
      await _open(tester, overrides: await unanalysed());
      await tester.ensureVisible(find.text('Analyse with Saaf AI'));
      await tester.tap(find.text('Analyse with Saaf AI'));
      await tester.pumpAndSettle();
      expect(find.text('Send your front photos?'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(skin.calls, 0);

      await tester.ensureVisible(find.text('Analyse with Saaf AI'));
      await tester.tap(find.text('Analyse with Saaf AI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      expect(skin.calls, 2);
    });
  });

  group('Pro gate', () {
    testWidgets('free users are told it is part of Saaf Pro', (tester) async {
      await _open(tester, overrides: _with(pro: false));
      expect(
        find.text('Progress tracking is part of Saaf Pro'),
        findsOneWidget,
      );
      expect(find.text('See Saaf Pro'), findsOneWidget);
      expect(find.text('Your progress'), findsNothing);
    });

    testWidgets('See Saaf Pro opens the paywall', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/monthly-progress',
        overrides: _with(pro: false),
      );
      await tester.pump();
      await tester.tap(find.text('See Saaf Pro'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('screen-paywall')), findsOneWidget);
    });
  });

  group('empty and error', () {
    testWidgets('Pro with fewer than two scans: explains and offers a scan', (
      tester,
    ) async {
      await _open(tester, overrides: _with());
      expect(find.text('Your first comparison is on its way'), findsOneWidget);
      expect(find.text('Take a scan'), findsOneWidget);
    });

    testWidgets('a failure can be retried', (tester) async {
      await _open(
        tester,
        overrides: _with(load: () async => throw StateError('x')),
      );
      expect(find.text('We couldn’t load your progress'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('comparison', () {
    testWidgets('header: week, title, dates and the photo count', (
      tester,
    ) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(find.text('WEEK 4'), findsOneWidget);
      expect(find.text('Your progress'), findsOneWidget);
      expect(find.text('14 Sep → 14 Oct  ·  2 aligned photos'), findsOneWidget);
    });

    testWidgets('the slider has the before and after dates', (tester) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(find.text('Before · 14 Sep'), findsOneWidget);
      expect(find.text('After · 14 Oct'), findsOneWidget);
    });

    testWidgets('the slider is announced for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(find.bySemanticsLabel('Compare before and after'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('shows the two biggest changes with the date they compare to', (
      tester,
    ) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(find.text('Dark spots'), findsOneWidget);
      expect(find.text('−18%'), findsOneWidget);
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('+6%'), findsOneWidget);
      expect(find.text('vs 14 Sep'), findsNWidgets(2));
    });

    testWidgets('a change card is read as one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(
        find.bySemanticsLabel('Dark spots: −18% vs 14 Sep'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('coach summary', () {
    testWidgets('names what improved', (tester) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      expect(find.text('Coach summary'), findsOneWidget);
      expect(
        find.text(
          'Good news: Dark spots improved. Daily sun protection keeps the '
          'progress, so keep it up.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('no change: steady', (tester) async {
      final view = await _view(
        progress: _progress(
          spots: 0,
          hydration: 0,
          spotsDirection: ChangeDirection.same,
        ),
      );
      await _open(tester, overrides: _with(view: view));
      expect(find.textContaining('looks steady since 14 Sep'), findsOneWidget);
    });

    testWidgets(
      'a clear slip: check the routine, see a professional if worried',
      (tester) async {
        final view = await _view(
          progress: _progress(
            spots: 20,
            hydration: 0,
            spotsDirection: ChangeDirection.worse,
          ),
        );
        await _open(tester, overrides: _with(view: view));
        expect(
          find.textContaining('a little worse than last time'),
          findsOneWidget,
        );
      },
    );
  });

  group('actions', () {
    testWidgets('sharing sends words only, never photos', (tester) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      await tester.tap(find.byTooltip('Share your progress'));
      await tester.pump();
      expect(_share.shared, hasLength(1));
      expect(_share.shared.single, contains('week 4'));
      expect(_share.shared.single, contains('Dark spots −18%'));
    });

    testWidgets('the check-in button opens the weekly check-in', (
      tester,
    ) async {
      final view = await _view();
      await pumpSaafApp(
        tester,
        location: '/monthly-progress',
        overrides: _with(view: view),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      await tester.pump();
      await tester.ensureVisible(find.text('Start your weekly check-in'));
      await tester.tap(find.text('Start your weekly check-in'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-weeklyCheckIn')),
        findsOneWidget,
      );
    });

    testWidgets('Take a scan opens the camera screen', (tester) async {
      await pumpSaafApp(
        tester,
        location: '/monthly-progress',
        overrides: _with(),
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Take a scan'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byKey(const ValueKey('screen-selfieCapture')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('navigation', () {
    testWidgets('lives in the bottom navigation, Progress selected', (
      tester,
    ) async {
      final view = await _view();
      await _open(tester, overrides: _with(view: view));
      for (final label in ['Home', 'Scan', 'Progress', 'Profile']) {
        expect(find.byTooltip(label), findsOneWidget, reason: label);
      }
    });
  });

  group('layout', () {
    testWidgets('the comparison is robust and accessible', (tester) async {
      final view = await _view();
      await tester.runAsync(() async {});
      await expectRobustLayoutSettled(
        tester,
        () => const MonthlyProgressScreen(),
        scaffold: false,
        overrides: _with(view: view),
        settlePumps: 3,
      );
      await _open(tester, overrides: _with(view: view));
      await expectTapTargetsAccessible(tester);
    });

    testWidgets('the locked and empty states are robust', (tester) async {
      await expectRobustLayoutSettled(
        tester,
        () => const MonthlyProgressScreen(),
        scaffold: false,
        overrides: _with(pro: false),
      );
      await expectRobustLayoutSettled(
        tester,
        () => const MonthlyProgressScreen(),
        scaffold: false,
        overrides: _with(),
      );
    });
  });
}
