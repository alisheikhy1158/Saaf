import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/data/services/http_ai_coach_service.dart';
import 'package:saaf/data/services/web/fake_weather_service.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/services/weather_service.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';

part 'weather_providers.g.dart';

/// Our server's weather (a demo day in the same builds as the demo AI).
@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) =>
    (kIsWeb || kDebugMode || Env.fakeCamera || !Env.useFirebase)
    ? const FakeWeatherService()
    : HttpAiCoachService(
        baseUrl: Env.aiProxyUrl,
        tokens: ref.watch(idTokenSourceProvider),
      );

/// The city the user chose for the skin weather; null until they choose.
@Riverpod(keepAlive: true)
class WeatherCity extends _$WeatherCity {
  @override
  Future<PkCity?> build() async => PkCity.byId(
    await ref.read(settingsRepositoryProvider).read(SettingNames.weatherCity),
  );

  Future<void> choose(PkCity city) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.weatherCity, city.id);
    state = AsyncData(city);
  }
}

/// Today's skin weather in the chosen city; null without a city.
@Riverpod(retry: noAutoRetry)
Future<SkinWeather?> skinWeather(Ref ref) async {
  final city = await ref.watch(weatherCityProvider.future);
  if (city == null) return null;
  final result = await ref.watch(weatherServiceProvider).today(city);
  return result.when(ok: (w) => w, err: (failure) => throw failure);
}
