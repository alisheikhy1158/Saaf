// Covers: the results screen only shows numbers read from the photo. Until
// Saaf AI has analysed the front photo (with the user's OK per send,
// store-compliance §5) it shows no numbers at all, never a guess from the quiz.
// The estimate says how sure it is about each measure and can be reported.
import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/fake_ai_coach_service.dart';
import 'package:saaf/data/services/web/in_memory_photo_store.dart';
import 'package:saaf/domain/entities/ai_skin_estimate.dart';
import 'package:saaf/domain/entities/completed_scan.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_skin_service.dart';
import 'package:saaf/domain/services/photo_shrinker.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/presentation/features/scan/screens/analysis_results_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _SkinService implements AiSkinService {
  final List<int> sentSizes = [];
  Result<AiSkinEstimate> answer = const Ok(
    AiSkinEstimate(
      usable: true,
      summary: 'Some shine on the forehead and a few small spots.',
      metrics: [
        SkinMetric(
          kind: SkinMetricKind.darkSpots,
          amount: 0.2,
          confidence: Confidence.medium,
          seen: 'A few small marks on the cheeks.',
        ),
        SkinMetric(
          kind: SkinMetricKind.breakouts,
          amount: 0.8,
          confidence: Confidence.high,
          seen: 'Several small spots on the chin.',
        ),
        SkinMetric(
          kind: SkinMetricKind.oiliness,
          amount: 0.6,
          confidence: Confidence.medium,
          seen: 'Shine on the T-zone.',
        ),
        SkinMetric(
          kind: SkinMetricKind.hydration,
          amount: 0.5,
          confidence: Confidence.low,
          seen: 'Hard to judge from a photo.',
        ),
      ],
    ),
  );

  @override
  Future<Result<AiSkinEstimate>> estimateSkin({
    required Uint8List photo,
    required String languageCode,
  }) async {
    sentSizes.add(photo.length);
    return answer;
  }
}

class _Shrinker implements PhotoShrinker {
  @override
  Future<Uint8List?> shrink(Uint8List photo) async => photo;
}

late _SkinService _service;
late InMemorySettingsRepository _settings;
late InMemoryPhotoStore _photos;
late CompletedScan _scan;

Future<List<Override>> _overrides({bool consented = true}) async {
  _settings = InMemorySettingsRepository();
  if (consented) {
    await _settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 17).toIso8601String(),
    );
  }
  _photos = InMemoryPhotoStore();
  final front = (await _photos.save(
    scanId: 'scan-1',
    pose: FacePose.front,
    bytes: solidPng(width: 8, height: 8, red: 180, green: 150, blue: 130),
  )).valueOrNull!;
  _scan = CompletedScan(
    id: 'scan-1',
    takenAt: DateTime(2026, 10, 17),
    photos: [front],
  );
  return [
    settingsRepositoryProvider.overrideWithValue(_settings),
    photoStoreProvider.overrideWithValue(_photos),
    photoShrinkerProvider.overrideWithValue(_Shrinker()),
    completedScanProvider.overrideWithBuild((ref, n) => _scan),
    aiSkinServiceProvider.overrideWithValue(_service),
    aiCoachServiceProvider.overrideWithValue(const FakeAiCoachService()),
  ];
}

Future<void> _open(WidgetTester tester, {bool consented = true}) async {
  await pumpSaaf(
    tester,
    const AnalysisResultsScreen(),
    scaffold: false,
    overrides: await _overrides(consented: consented),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => _service = _SkinService());

  testWidgets('an unanalysed scan shows no numbers, only a way to analyse', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Not analysed yet'), findsOneWidget);
    expect(find.textContaining('never a guess'), findsOneWidget);
    expect(find.text('Analyse my photo with Saaf AI'), findsOneWidget);
    expect(find.text('Skin score'), findsNothing);
    expect(find.text('Dark spots'), findsNothing);
    expect(find.textContaining('quiz'), findsNothing);
  });

  testWidgets('without Saaf AI: offers to turn it on, sends nothing', (
    tester,
  ) async {
    await _open(tester, consented: false);
    expect(find.text('Turn on Saaf AI'), findsOneWidget);
    expect(find.text('Analyse my photo with Saaf AI'), findsNothing);
    expect(_service.sentSizes, isEmpty);
  });

  testWidgets('asks before sending, and Not now sends nothing', (tester) async {
    await _open(tester);
    await _tap(tester, 'Analyse my photo with Saaf AI');
    expect(find.text('Send your front photo?'), findsOneWidget);
    expect(
      find.textContaining('side photos stay on your phone'),
      findsOneWidget,
    );
    await _tap(tester, 'Not now');
    expect(_service.sentSizes, isEmpty);
  });

  testWidgets('after sending: the AI estimate, how sure it is, what it saw', (
    tester,
  ) async {
    await _open(tester);
    await _tap(tester, 'Analyse my photo with Saaf AI');
    await _tap(tester, 'Send');
    expect(_service.sentSizes, hasLength(1));
    expect(find.text('Estimated by Saaf AI from your photo'), findsOneWidget);
    expect(find.text('Not analysed yet'), findsNothing);
    expect(find.text('Skin score'), findsOneWidget);
    expect(
      find.text('Some shine on the forehead and a few small spots.'),
      findsOneWidget,
    );
    expect(find.textContaining('not a measurement'), findsOneWidget);
    expect(find.text('How sure: High'), findsOneWidget); // breakouts
    expect(find.text('How sure: Low'), findsOneWidget); // hydration
    expect(find.text('High'), findsOneWidget); // breakouts 0.8 rating
    expect(
      find.textContaining('Several small spots on the chin.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Report this answer'), findsOneWidget);
    // Kept on the phone for this scan.
    expect(await _settings.read('aiSkinEstimates'), contains('scan-1'));
  });

  testWidgets('a photo Saaf AI cannot judge: says why, still no numbers', (
    tester,
  ) async {
    _service.answer = const Ok(
      AiSkinEstimate(usable: false, problem: 'The photo is too dark.'),
    );
    await _open(tester);
    await _tap(tester, 'Analyse my photo with Saaf AI');
    await _tap(tester, 'Send');
    expect(find.textContaining('The photo is too dark.'), findsOneWidget);
    expect(find.text('Not analysed yet'), findsOneWidget);
    expect(find.text('Skin score'), findsNothing);
  });

  testWidgets('a failure can be tried again', (tester) async {
    _service.answer = const Err(NetworkFailure());
    await _open(tester);
    await _tap(tester, 'Analyse my photo with Saaf AI');
    await _tap(tester, 'Send');
    expect(find.textContaining('connection'), findsOneWidget);
    expect(find.text('Analyse my photo with Saaf AI'), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    final overrides = await _overrides();
    await expectRobustLayoutSettled(
      tester,
      () => const AnalysisResultsScreen(),
      scaffold: false,
      overrides: overrides,
    );
  });
}
