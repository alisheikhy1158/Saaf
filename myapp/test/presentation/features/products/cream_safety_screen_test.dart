// Covers: the "Is this cream safe?" screen — explains what is sent, sends only
// on a tap, shows a clear verdict with what was found and where (sources open
// in the browser), never says "safe", and can be reported (Play AI policy)
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/fake_ai_coach_service.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/safety_check.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/domain/services/ai_safety_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/presentation/features/products/screens/cream_safety_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _Service implements AiSafetyService {
  final List<CreamQuery> asked = [];
  Result<SafetyCheck> answer = const Ok(
    SafetyCheck(
      found: true,
      title: 'Glow Formula Beauty Cream',
      level: SafetyLevel.danger,
      summary: 'Reported to contain mercury.',
      ingredients: ['Mercurous chloride', 'Paraffin'],
      ingredientsPrinted: true,
      findings: [
        SafetyFinding(
          text: 'Pakistan’s standards authority found mercury.',
          source: 'https://psqca.example.gov.pk/notice/12',
        ),
      ],
    ),
  );

  @override
  Future<Result<SafetyCheck>> checkSafety({
    required CreamQuery query,
    required AiContext context,
  }) async {
    asked.add(query);
    return answer;
  }
}

class _Picker implements AiPhotoPicker {
  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async =>
      Ok(solidPng(width: 8, height: 8, red: 200, green: 200, blue: 200));
}

late _Service _service;
late FakeExternalLinkService _links;

List<Override> _overrides({bool consented = true}) {
  final settings = InMemorySettingsRepository();
  if (consented) {
    settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 18).toIso8601String(),
    );
  }
  return [
    settingsRepositoryProvider.overrideWithValue(settings),
    aiSafetyServiceProvider.overrideWithValue(_service),
    aiCoachServiceProvider.overrideWithValue(const FakeAiCoachService()),
    aiPhotoPickerProvider.overrideWithValue(_Picker()),
    externalLinkServiceProvider.overrideWithValue(_links),
  ];
}

Future<void> _open(WidgetTester tester, {bool consented = true}) async {
  await pumpSaafApp(
    tester,
    location: '/cream-check',
    overrides: _overrides(consented: consented),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _service = _Service();
    _links = FakeExternalLinkService();
  });

  testWidgets('explains what it checks and what is sent', (tester) async {
    await _open(tester);
    expect(find.text('Is this cream safe?'), findsWidgets);
    expect(find.textContaining('mercury'), findsWidgets);
    expect(find.textContaining('Only the photo or the name'), findsOneWidget);
    expect(_service.asked, isEmpty);
  });

  testWidgets('a typed name is checked after a tap', (tester) async {
    await _open(tester);
    await tester.enterText(
      find.byKey(const ValueKey('cream-name')),
      'Glow Formula',
    );
    await _tap(tester, find.text('Check it'));
    expect(_service.asked, [const CreamNameQuery('Glow Formula')]);
  });

  testWidgets('a label photo is checked after a tap', (tester) async {
    await _open(tester);
    await _tap(tester, find.text('Take a photo of the label'));
    expect(_service.asked, isEmpty);
    await _tap(tester, find.text('Check it'));
    expect(_service.asked.single, isA<CreamPhotoQuery>());
  });

  testWidgets('danger: a clear verdict, the flagged ingredient, sources', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(find.byKey(const ValueKey('cream-name')), 'Glow');
    await _tap(tester, find.text('Check it'));
    expect(find.text('Danger: don’t use it'), findsOneWidget);
    expect(find.textContaining('Mercurous chloride'), findsWidgets);
    expect(find.textContaining('standards authority'), findsOneWidget);
    expect(find.text('AI answer'), findsOneWidget);
    expect(find.byTooltip('Report this answer'), findsOneWidget);
    await _tap(tester, find.text('psqca.example.gov.pk'));
    expect(_links.opened, ['https://psqca.example.gov.pk/notice/12']);
  });

  testWidgets('no known problem is never called "safe"', (tester) async {
    _service.answer = const Ok(
      SafetyCheck(
        found: true,
        title: 'Plain Moisturiser',
        level: SafetyLevel.noKnownProblem,
        ingredients: ['Water', 'Glycerin'],
        ingredientsPrinted: true,
      ),
    );
    await _open(tester);
    await tester.enterText(find.byKey(const ValueKey('cream-name')), 'Plain');
    await _tap(tester, find.text('Check it'));
    expect(find.text('No known problem found'), findsOneWidget);
    expect(find.textContaining('can still'), findsOneWidget);
    expect(find.text('Safe'), findsNothing);
  });

  testWidgets('without Saaf AI: offers to turn it on', (tester) async {
    await _open(tester, consented: false);
    expect(find.text('Turn on Saaf AI'), findsOneWidget);
    expect(find.text('Check it'), findsNothing);
  });

  testWidgets('a failure can be retried', (tester) async {
    _service.answer = const Err(NetworkFailure());
    await _open(tester);
    await tester.enterText(find.byKey(const ValueKey('cream-name')), 'Glow');
    await _tap(tester, find.text('Check it'));
    expect(find.textContaining('connection'), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await expectRobustLayoutSettled(
      tester,
      () => const CreamSafetyScreen(),
      scaffold: false,
      overrides: _overrides(),
    );
  });
}
