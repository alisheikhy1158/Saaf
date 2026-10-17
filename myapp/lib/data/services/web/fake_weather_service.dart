import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/services/weather_service.dart';

/// A sunny, humid demo day for Chrome and builds without the server.
class FakeWeatherService implements WeatherService {
  const FakeWeatherService();

  @override
  Future<Result<SkinWeather>> today(PkCity city) async => const Ok(
    SkinWeather(temperatureC: 33, humidity: 72, uvNow: 7, uvMax: 9, aqi: 120),
  );
}
