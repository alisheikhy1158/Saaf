import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';

/// Today's skin weather for a city, through our own server (only the city's
/// place is sent).
abstract interface class WeatherService {
  Future<Result<SkinWeather>> today(PkCity city);
}
