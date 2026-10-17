// Covers: looking a product up with Saaf AI (from a label photo, a barcode
// nobody knows or a QR code) — consent first, the user sees what is sent and
// taps to send, the answer is marked as AI and can be reported (Play AI policy)
import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/core/utils/solid_png.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/fake_ai_coach_service.dart';
import 'package:saaf/domain/entities/ai_context.dart';
import 'package:saaf/domain/entities/ai_photo_source.dart';
import 'package:saaf/domain/entities/product_insight.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/services/ai_photo_picker.dart';
import 'package:saaf/domain/services/ai_product_service.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/presentation/features/products/screens/product_ai_screen.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _Service implements AiProductService {
  final List<ProductQuery> asked = [];
  Result<ProductInsight> answer = const Ok(
    ProductInsight(
      title: 'CeraVe Foaming Facial Cleanser',
      text:
          '**What it is**\n- A gentle **foaming** gel wash.\n'
          '**For your skin**\n- Suits oily skin.',
      webChecked: true,
    ),
  );

  @override
  Future<Result<ProductInsight>> lookUpProduct({
    required ProductQuery query,
    required AiContext context,
  }) async {
    asked.add(query);
    return answer;
  }

  @override
  Future<Result<AiRoutinePlan>> planRoutine({
    required AiContext context,
    required List<String> currentProducts,
    Map<SkinMetricKind, double> scan = const {},
  }) async => const Err(ServiceUnavailable());
}

class _Picker implements AiPhotoPicker {
  final List<AiPhotoSource> sources = [];

  @override
  Future<Result<Uint8List?>> pick(AiPhotoSource source) async {
    sources.add(source);
    return Ok(solidPng(width: 24, height: 32, red: 200, green: 200, blue: 200));
  }
}

late _Service _service;
late _Picker _picker;

List<Override> _overrides({bool consented = true}) {
  final settings = InMemorySettingsRepository();
  if (consented) {
    settings.write(
      AiConsent.settingName,
      DateTime(2026, 10, 17).toIso8601String(),
    );
  }
  return [
    settingsRepositoryProvider.overrideWithValue(settings),
    aiProductServiceProvider.overrideWithValue(_service),
    aiCoachServiceProvider.overrideWithValue(const FakeAiCoachService()),
    aiPhotoPickerProvider.overrideWithValue(_picker),
  ];
}

Future<void> _open(
  WidgetTester tester,
  String location, {
  bool consented = true,
}) async {
  await pumpSaafApp(
    tester,
    location: location,
    overrides: _overrides(consented: consented),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(() {
    _service = _Service();
    _picker = _Picker();
  });

  group('a label photo', () {
    testWidgets('says what is sent, and sends only after the user taps', (
      tester,
    ) async {
      await _open(tester, '/product-ai?photo=1');
      expect(find.text('Look up a product from a photo'), findsOneWidget);
      expect(find.textContaining('Only this photo'), findsOneWidget);
      await _tap(tester, find.text('Take a photo'));
      expect(_picker.sources, [AiPhotoSource.camera]);
      expect(_service.asked, isEmpty);
      await _tap(tester, find.text('Look it up'));
      expect(_service.asked.single, isA<ProductPhotoQuery>());
    });

    testWidgets('the gallery works too', (tester) async {
      await _open(tester, '/product-ai?photo=1');
      await _tap(tester, find.text('Choose from gallery'));
      expect(_picker.sources, [AiPhotoSource.gallery]);
    });

    testWidgets('shows a tidy AI answer that can be reported', (tester) async {
      await _open(tester, '/product-ai?photo=1');
      await _tap(tester, find.text('Take a photo'));
      await _tap(tester, find.text('Look it up'));
      expect(find.text('AI answer'), findsOneWidget);
      expect(find.text('CeraVe Foaming Facial Cleanser'), findsOneWidget);
      expect(find.text('What it is'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);
      expect(find.byTooltip('Report this answer'), findsOneWidget);
      expect(find.textContaining('AI answers can be wrong'), findsOneWidget);
    });

    testWidgets('not a product: asks for a clearer photo', (tester) async {
      _service.answer = const Ok(ProductInsight.notFound());
      await _open(tester, '/product-ai?photo=1');
      await _tap(tester, find.text('Take a photo'));
      await _tap(tester, find.text('Look it up'));
      expect(
        find.text('Saaf AI couldn’t tell which product this is'),
        findsOneWidget,
      );
      expect(find.text('Take a photo'), findsOneWidget);
    });
  });

  group('a barcode or a QR code', () {
    testWidgets('a barcode is looked up after a tap', (tester) async {
      await _open(tester, '/product-ai?barcode=3337875743563');
      expect(find.textContaining('3337875743563'), findsOneWidget);
      await _tap(tester, find.text('Look it up'));
      expect(_service.asked, [const ProductBarcodeQuery('3337875743563')]);
    });

    testWidgets('QR text is shown, then looked up', (tester) async {
      await _open(tester, '/product-ai?qr=https%3A%2F%2Fbrand.pk%2Fneem');
      expect(find.textContaining('https://brand.pk/neem'), findsOneWidget);
      await _tap(tester, find.text('Look it up'));
      expect(_service.asked, [const ProductQrQuery('https://brand.pk/neem')]);
    });

    testWidgets('says when the web could not be checked', (tester) async {
      _service.answer = const Ok(
        ProductInsight(title: 'X', text: 'A wash.', webChecked: false),
      );
      await _open(tester, '/product-ai?barcode=3337875743563');
      await _tap(tester, find.text('Look it up'));
      expect(find.textContaining('couldn’t search the web'), findsOneWidget);
    });

    testWidgets('a failure can be retried', (tester) async {
      _service.answer = const Err(NetworkFailure());
      await _open(tester, '/product-ai?barcode=3337875743563');
      await _tap(tester, find.text('Look it up'));
      expect(find.text('Try again'), findsOneWidget);
      _service.answer = const Ok(
        ProductInsight(title: 'X', text: 'A wash.', webChecked: true),
      );
      await _tap(tester, find.text('Try again'));
      expect(_service.asked, hasLength(2));
      expect(find.text('A wash.'), findsOneWidget);
    });
  });

  testWidgets(
    'without Saaf AI turned on: nothing is sent, offers to turn it on',
    (tester) async {
      await _open(
        tester,
        '/product-ai?barcode=3337875743563',
        consented: false,
      );
      expect(find.text('Turn on Saaf AI'), findsOneWidget);
      expect(find.text('Look it up'), findsNothing);
      expect(_service.asked, isEmpty);
    },
  );

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await expectRobustLayoutSettled(
      tester,
      () => const ProductAiScreen(barcode: '3337875743563'),
      scaffold: false,
      overrides: _overrides(),
    );
  });
}
