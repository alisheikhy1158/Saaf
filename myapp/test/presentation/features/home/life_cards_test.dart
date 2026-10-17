// Covers: Home cards for introducing a new product slowly (with a daily
// "any reaction?" check-in), for getting ready for an event, and Ramadan tips
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/domain/entities/introduction.dart';
import 'package:saaf/domain/entities/life_event.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/presentation/features/home/widgets/life_cards.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

import '../../../helpers/pump_app.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 18, 9);
}

late InMemorySettingsRepository _settings;

Future<void> _open(WidgetTester tester) async {
  await pumpSaaf(
    tester,
    const SingleChildScrollView(child: LifeCards()),
    overrides: <Override>[
      settingsRepositoryProvider.overrideWithValue(_settings),
      clockProvider.overrideWithValue(_Clock()),
    ],
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() => _settings = InMemorySettingsRepository());

  testWidgets('nothing going on: no cards', (tester) async {
    await _open(tester);
    expect(find.byType(Card), findsNothing);
    expect(find.textContaining('Introducing'), findsNothing);
  });

  group('introducing a new product', () {
    Future<void> started(int daysAgo) => _settings.write(
      SettingNames.introduction,
      Introduction(
        productName: 'Retinol serum',
        startedOn: DateTime(2026, 10, 18).subtract(Duration(days: daysAgo)),
      ).encode(),
    );

    testWidgets('shows today’s step and asks about reactions', (tester) async {
      await started(5);
      await _open(tester);
      expect(find.text('Introducing Retinol serum'), findsOneWidget);
      expect(find.textContaining('2 nights a week'), findsOneWidget);
      expect(find.text('Any reaction today?'), findsOneWidget);
      await _tap(tester, 'No');
      expect(find.text('Any reaction today?'), findsNothing);
      expect(await _settings.read(SettingNames.introduction), contains('none'));
    });

    testWidgets('a strong reaction: stop, with advice', (tester) async {
      await started(5);
      await _open(tester);
      await _tap(tester, 'Strong');
      expect(find.textContaining('Stop using Retinol serum'), findsOneWidget);
      await _tap(tester, 'Done');
      expect(await _settings.read(SettingNames.introduction), isNull);
    });

    testWidgets('first two days: the patch test', (tester) async {
      await started(0);
      await _open(tester);
      expect(find.textContaining('Patch test'), findsOneWidget);
    });
  });

  group('an event', () {
    testWidgets('counts down with the right advice', (tester) async {
      await _settings.write(
        SettingNames.lifeEvent,
        LifeEvent(name: 'My wedding', date: DateTime(2026, 10, 30)).encode(),
      );
      await _open(tester);
      expect(find.text('My wedding in 12 days'), findsOneWidget);
      expect(find.textContaining('Nothing new now'), findsOneWidget);
    });

    testWidgets('an event that has passed is not shown', (tester) async {
      await _settings.write(
        SettingNames.lifeEvent,
        LifeEvent(name: 'Mehndi', date: DateTime(2026, 10, 1)).encode(),
      );
      await _open(tester);
      expect(find.textContaining('Mehndi'), findsNothing);
    });
  });

  testWidgets('Ramadan mode: fasting-friendly tips', (tester) async {
    await _settings.write(SettingNames.ramadanMode, 'on');
    await _open(tester);
    expect(find.text('Ramadan skin care'), findsOneWidget);
    expect(find.textContaining('between iftar and sehri'), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await _settings.write(SettingNames.ramadanMode, 'on');
    await _settings.write(
      SettingNames.lifeEvent,
      LifeEvent(name: 'My wedding', date: DateTime(2026, 10, 30)).encode(),
    );
    await _settings.write(
      SettingNames.introduction,
      Introduction(
        productName: 'Retinol serum',
        startedOn: DateTime(2026, 10, 13),
      ).encode(),
    );
    await expectRobustLayoutSettled(
      tester,
      () => const SingleChildScrollView(child: LifeCards()),
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_settings),
        clockProvider.overrideWithValue(_Clock()),
      ],
    );
  });
}
