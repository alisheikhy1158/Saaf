// Covers: daily skin tips from the local weather (UV, smog, heat, humidity) —
// most important first, at most three, nothing made up when data is missing
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/usecases/skin_weather_tips.dart';

List<WeatherTipKind> kinds(SkinWeather w) => [
  for (final tip in const SkinWeatherTips()(w)) tip.kind,
];

void main() {
  test('very strong sun comes first, with the day’s highest UV', () {
    final tips = const SkinWeatherTips()(
      const SkinWeather(temperatureC: 30, uvNow: 4, uvMax: 11),
    );
    expect(tips.first.kind, WeatherTipKind.uvExtreme);
    expect(tips.first.value, 11);
  });

  test('UV bands', () {
    expect(
      kinds(const SkinWeather(temperatureC: 25, uvMax: 7)).first,
      WeatherTipKind.uvHigh,
    );
    expect(
      kinds(const SkinWeather(temperatureC: 25, uvMax: 4)).first,
      WeatherTipKind.uvModerate,
    );
    expect(
      kinds(const SkinWeather(temperatureC: 25, uvMax: 1)).first,
      WeatherTipKind.uvLow,
    );
  });

  test('no UV figure: no UV tip (nothing is guessed)', () {
    expect(kinds(const SkinWeather(temperatureC: 25, humidity: 50)), isEmpty);
  });

  test('smog, then heat, then humidity; three at most', () {
    expect(
      kinds(
        const SkinWeather(temperatureC: 40, humidity: 80, uvMax: 9, aqi: 210),
      ),
      [WeatherTipKind.uvExtreme, WeatherTipKind.smog, WeatherTipKind.heat],
    );
  });

  test('hazy air is a gentler tip than smog', () {
    expect(kinds(const SkinWeather(temperatureC: 25, uvMax: 2, aqi: 120)), [
      WeatherTipKind.uvLow,
      WeatherTipKind.haze,
    ]);
  });

  test('humid or dry air changes the moisturiser tip', () {
    expect(
      kinds(const SkinWeather(temperatureC: 30, uvMax: 2, humidity: 75)),
      contains(WeatherTipKind.humid),
    );
    expect(
      kinds(const SkinWeather(temperatureC: 15, uvMax: 2, humidity: 25)),
      contains(WeatherTipKind.dry),
    );
  });

  test('the city list has Pakistan’s big cities with their places', () {
    final lahore = PkCity.all.firstWhere((c) => c.id == 'lahore');
    expect(lahore.lat, closeTo(31.55, 0.1));
    expect(lahore.lon, closeTo(74.34, 0.1));
    expect(PkCity.all.map((c) => c.id), containsAll(['karachi', 'islamabad']));
    expect(PkCity.byId('karachi')?.id, 'karachi');
    expect(PkCity.byId('atlantis'), isNull);
  });
}
