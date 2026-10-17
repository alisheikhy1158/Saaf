// Covers: Home reminds the user before a product runs out or passes its
// use-by date (worked out on the phone from the shelf)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/home/widgets/shelf_card.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 18, 9);
}

Future<List<Override>> _with(List<OwnedProduct> products) async {
  final settings = InMemorySettingsRepository();
  await settings.write(
    SettingNames.currentProducts,
    OwnedProduct.encodeList(products),
  );
  return [
    settingsRepositoryProvider.overrideWithValue(settings),
    clockProvider.overrideWithValue(_Clock()),
  ];
}

Future<void> _open(WidgetTester tester, List<OwnedProduct> products) async {
  await pumpSaaf(
    tester,
    const SingleChildScrollView(child: ShelfCard()),
    overrides: await _with(products),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('says which product runs out soon and which has expired', (
    tester,
  ) async {
    await _open(tester, [
      OwnedProduct(
        name: 'Nivea Soft',
        step: ProductCategory.moisturiser,
        openedOn: DateTime(2026, 9, 25),
        lastsWeeks: 4,
      ),
      OwnedProduct(
        name: 'Old Sunscreen',
        step: ProductCategory.sunscreen,
        openedOn: DateTime(2025, 9, 1),
        paoMonths: 12,
      ),
    ]);
    expect(find.text('Your shelf'), findsOneWidget);
    expect(find.textContaining('Nivea Soft'), findsOneWidget);
    expect(find.textContaining('runs out'), findsOneWidget);
    expect(find.textContaining('Old Sunscreen'), findsOneWidget);
    expect(find.textContaining('past its use-by date'), findsOneWidget);
  });

  testWidgets('nothing to say: no card', (tester) async {
    await _open(tester, const [OwnedProduct(name: 'Plain')]);
    expect(find.text('Your shelf'), findsNothing);
  });
}
