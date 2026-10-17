/// Today's weather where the user lives, as far as skin is concerned. Any
/// figure the source did not give is null (and then no tip is made from it).
class SkinWeather {
  const SkinWeather({
    required this.temperatureC,
    this.humidity,
    this.uvNow,
    this.uvMax,
    this.aqi,
    this.pm25,
  });

  final int temperatureC;

  /// Relative humidity, %.
  final int? humidity;
  final double? uvNow;

  /// Today's highest UV index.
  final double? uvMax;

  /// US air quality index.
  final int? aqi;
  final int? pm25;
}
