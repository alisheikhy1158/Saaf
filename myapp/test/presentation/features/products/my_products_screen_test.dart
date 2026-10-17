// Covers: the products the user uses now — asked right after the skin quiz
// (and editable from Profile), kept on the phone, so Saaf AI can say which to
// keep and which to change
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/presentation/features/products/screens/my_products_screen.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

late InMemorySettingsRepository _settings;

List<Override> _overrides() => [
  settingsRepositoryProvider.overrideWithValue(_settings),
];

Future<void> _open(WidgetTester tester, {bool setup = false}) async {
  await pumpSaafApp(
    tester,
    location: setup ? '/my-products?setup=1' : '/my-products',
    overrides: _overrides(),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _add(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(const ValueKey('product-name')), name);
  await tester.ensureVisible(find.text('Add'));
  await tester.tap(find.text('Add'));
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUp(() => _settings = InMemorySettingsRepository());

  testWidgets('explains why it asks and that the names stay on the phone', (
    tester,
  ) async {
    await _open(tester, setup: true);
    expect(find.text('Products you use now'), findsWidgets);
    expect(find.textContaining('which to keep'), findsOneWidget);
    expect(find.textContaining('stay on your phone'), findsOneWidget);
    expect(find.text('No products added yet.'), findsOneWidget);
  });

  testWidgets('adds and removes products, and keeps them', (tester) async {
    await _open(tester);
    await _add(tester, '  Nivea   Soft ');
    await _add(tester, 'Himalaya Neem Face Wash');
    await _add(tester, 'nivea soft'); // already there
    expect(find.text('Nivea Soft'), findsOneWidget);
    expect(find.text('Himalaya Neem Face Wash'), findsOneWidget);
    expect(
      await _settings.read(SettingNames.currentProducts),
      '["Nivea Soft","Himalaya Neem Face Wash"]',
    );

    await _tap(tester, find.byTooltip('Remove Nivea Soft'));
    expect(find.text('Nivea Soft'), findsNothing);
    expect(
      await _settings.read(SettingNames.currentProducts),
      '["Himalaya Neem Face Wash"]',
    );
  });

  testWidgets('stops at 10 products and says so', (tester) async {
    await _open(tester);
    for (var i = 1; i <= 10; i++) {
      await _add(tester, 'Product $i');
    }
    await _add(tester, 'Product 11');
    // Still typed in the field, but not added to the list.
    final saved = await _settings.read(SettingNames.currentProducts);
    expect(saved, isNot(contains('Product 11')));
    expect(saved, contains('Product 10'));
    expect(find.text('You can add up to 10 products.'), findsOneWidget);
  });

  testWidgets('in setup, Continue and Skip both go on to the face scan', (
    tester,
  ) async {
    await _open(tester, setup: true);
    await _add(tester, 'Nivea Soft');
    await _tap(tester, find.text('Continue'));
    expect(find.byKey(const ValueKey('screen-selfieCapture')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _open(tester, setup: true);
    await _tap(tester, find.text('Skip'));
    expect(find.byKey(const ValueKey('screen-selfieCapture')), findsOneWidget);
  });

  testWidgets('from Profile it has Done instead of the setup buttons', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('Profile has a row that opens it', (tester) async {
    await pumpSaafApp(tester, location: '/profile', overrides: _overrides());
    await tester.pump();
    await _tap(tester, find.text('Products you use'));
    expect(find.byKey(const ValueKey('screen-myProducts')), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await expectRobustLayoutSettled(
      tester,
      () => const MyProductsScreen(setup: true),
      scaffold: false,
      overrides: _overrides(),
    );
  });
}
