import 'package:saaf/domain/entities/skin_weather.dart';

enum WeatherTipKind {
  uvExtreme,
  uvHigh,
  uvModerate,
  uvLow,
  smog,
  haze,
  heat,
  humid,
  dry,
}

/// One tip; [value] is the figure it is about (the UV, the AQI…) when it has one.
class WeatherTip {
  const WeatherTip(this.kind, [this.value]);

  final WeatherTipKind kind;
  final num? value;
}

/// Turns today's weather into at most three skin tips, most important first:
/// sun, then the air, then heat, then humidity. Pure rules (WHO UV bands, US
/// AQI bands); a missing figure gives no tip rather than a guess.
class SkinWeatherTips {
  const SkinWeatherTips();

  static const int maxTips = 3;

  List<WeatherTip> call(SkinWeather weather) {
    final tips = <WeatherTip>[];

    final uv = weather.uvMax ?? weather.uvNow;
    if (uv != null) {
      final shown = uv.round();
      tips.add(switch (uv) {
        >= 8 => WeatherTip(WeatherTipKind.uvExtreme, shown),
        >= 6 => WeatherTip(WeatherTipKind.uvHigh, shown),
        >= 3 => WeatherTip(WeatherTipKind.uvModerate, shown),
        _ => WeatherTip(WeatherTipKind.uvLow, shown),
      });
    }

    final aqi = weather.aqi;
    if (aqi != null && aqi > 150) {
      tips.add(WeatherTip(WeatherTipKind.smog, aqi));
    } else if (aqi != null && aqi > 100) {
      tips.add(WeatherTip(WeatherTipKind.haze, aqi));
    }

    if (weather.temperatureC >= 38) {
      tips.add(WeatherTip(WeatherTipKind.heat, weather.temperatureC));
    }

    final humidity = weather.humidity;
    if (humidity != null && humidity >= 70) {
      tips.add(WeatherTip(WeatherTipKind.humid, humidity));
    } else if (humidity != null && humidity <= 30) {
      tips.add(WeatherTip(WeatherTipKind.dry, humidity));
    }

    return tips.take(maxTips).toList();
  }
}
