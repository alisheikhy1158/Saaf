// Covers: the daily "skin weather" card on Home — the user picks a city (no
// location permission), sees today's sun, air and humidity as skin tips, with
// the data source credited (Open-Meteo / CAMS licence)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/data/repositories/in_memory_extra_repositories.dart';
import 'package:saaf/data/services/web/fake_external_link_service.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/services/weather_service.dart';
import 'package:saaf/presentation/features/home/widgets/skin_weather_card.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/weather_providers.dart';

import '../../../helpers/pump_app.dart';

class _Weather implements WeatherService {
  final List<String> asked = [];
  Result<SkinWeather> answer = const Ok(
    SkinWeather(temperatureC: 39, humidity: 74, uvNow: 9, uvMax: 11, aqi: 172),
  );

  @override
  Future<Result<SkinWeather>> today(PkCity city) async {
    asked.add(city.id);
    return answer;
  }
}

late _Weather _weather;
late InMemorySettingsRepository _settings;
late FakeExternalLinkService _links;

List<Override> _overrides() => [
  weatherServiceProvider.overrideWithValue(_weather),
  settingsRepositoryProvider.overrideWithValue(_settings),
  externalLinkServiceProvider.overrideWithValue(_links),
];

Future<void> _open(WidgetTester tester) async {
  await pumpSaaf(
    tester,
    const SingleChildScrollView(child: SkinWeatherCard()),
    overrides: _overrides(),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
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
    _weather = _Weather();
    _settings = InMemorySettingsRepository();
    _links = FakeExternalLinkService();
  });

  testWidgets('without a city: offers to choose one, asks for nothing', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Choose your city'), findsOneWidget);
    expect(_weather.asked, isEmpty);
  });

  testWidgets('choosing a city shows today’s skin weather and tips', (
    tester,
  ) async {
    await _open(tester);
    await _tap(tester, find.text('Choose your city'));
    await _tap(tester, find.text('Lahore'));
    expect(_weather.asked, ['lahore']);
    expect(await _settings.read(SettingNames.weatherCity), 'lahore');
    expect(find.text('Skin weather · Lahore'), findsOneWidget);
    expect(find.text('UV 11'), findsOneWidget);
    expect(find.textContaining('Very strong sun'), findsOneWidget);
    expect(find.textContaining('Smoggy air'), findsOneWidget);
    expect(find.textContaining('Hot day'), findsOneWidget);
  });

  testWidgets('credits the data source with a link', (tester) async {
    await _settings.write(SettingNames.weatherCity, 'karachi');
    await _open(tester);
    await _tap(tester, find.textContaining('Open-Meteo'));
    expect(_links.opened, ['https://open-meteo.com/']);
  });

  testWidgets('the city can be changed', (tester) async {
    await _settings.write(SettingNames.weatherCity, 'karachi');
    await _open(tester);
    expect(find.text('Skin weather · Karachi'), findsOneWidget);
    await _tap(tester, find.byTooltip('Change city'));
    await _tap(tester, find.text('Peshawar'));
    expect(find.text('Skin weather · Peshawar'), findsOneWidget);
  });

  testWidgets('no weather: says so and can try again', (tester) async {
    _weather.answer = const Err(NetworkFailure());
    await _settings.write(SettingNames.weatherCity, 'karachi');
    await _open(tester);
    expect(find.text('Couldn’t load today’s weather.'), findsOneWidget);
    _weather.answer = const Ok(SkinWeather(temperatureC: 20, uvMax: 2));
    await _tap(tester, find.text('Try again'));
    expect(find.textContaining('Low sun'), findsOneWidget);
  });

  testWidgets('is robust at every size, 200 % text and in Urdu', (
    tester,
  ) async {
    await _settings.write(SettingNames.weatherCity, 'lahore');
    await expectRobustLayoutSettled(
      tester,
      () => const SingleChildScrollView(child: SkinWeatherCard()),
      overrides: _overrides(),
    );
  });
}
