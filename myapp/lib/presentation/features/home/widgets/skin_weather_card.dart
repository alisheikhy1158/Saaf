import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/domain/entities/skin_weather.dart';
import 'package:saaf/domain/usecases/skin_weather_tips.dart';
import 'package:saaf/presentation/providers/product_providers.dart';
import 'package:saaf/presentation/providers/weather_providers.dart';
import 'package:saaf/presentation/widgets/common/city_name.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';

/// Home: today's "skin weather" in the user's city (sun, air, heat,
/// humidity) as up to three tips. The user picks a city from a list (no
/// location permission); the data source is credited as its licence asks.
class SkinWeatherCard extends ConsumerWidget {
  const SkinWeatherCard({super.key});

  static const _sourceUrl = 'https://open-meteo.com/';

  Future<void> _pickCity(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final city = await showModalBottomSheet<PkCity>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.all(context.saaf.space.x16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.saaf.space.x4,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.weatherCitySheetTitle,
                      style: context.text.titleMedium,
                    ),
                  ),
                  Text(l10n.weatherCityNote, style: context.text.bodySmall),
                ],
              ),
            ),
            for (final city in PkCity.all)
              ListTile(
                title: Text(cityName(l10n, city)),
                onTap: () => Navigator.of(context).pop(city),
              ),
          ],
        ),
      ),
    );
    if (city != null) await ref.read(weatherCityProvider.notifier).choose(city);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final city = ref.watch(weatherCityProvider);

    Widget card(List<Widget> children) => DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageTint,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.x16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: space.x8,
          children: children,
        ),
      ),
    );

    final chosen = city.value;
    if (!city.hasValue) return const SizedBox.shrink();
    if (chosen == null) {
      return card([
        Row(
          spacing: space.x8,
          children: [
            const ExcludeSemantics(child: Icon(Icons.wb_sunny_outlined)),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.weatherOfferTitle,
                  style: tokens.styles.listTitle,
                ),
              ),
            ),
          ],
        ),
        Text(l10n.weatherOfferBody, style: tokens.styles.pointCaption),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SaafButton.text(
            label: l10n.weatherPickCity,
            onPressed: () => _pickCity(context, ref),
          ),
        ),
      ]);
    }

    final weather = ref.watch(skinWeatherProvider);
    return card([
      Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                l10n.weatherTitle(cityName(l10n, chosen)),
                style: tokens.styles.listTitle,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.weatherChangeCity,
            icon: const Icon(Icons.edit_location_alt_outlined),
            onPressed: () => _pickCity(context, ref),
          ),
        ],
      ),
      if (weather.hasError && !weather.hasValue) ...[
        Text(l10n.weatherUnavailable, style: tokens.styles.pointCaption),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SaafButton.text(
            label: l10n.scanTryAgain,
            onPressed: () => ref.invalidate(skinWeatherProvider),
          ),
        ),
      ] else if (weather.value case final today?)
        ..._today(context, ref, today)
      else
        Center(
          child: SizedBox.square(
            dimension: tokens.size.icon,
            child: const CircularProgressIndicator(),
          ),
        ),
    ]);
  }

  List<Widget> _today(BuildContext context, WidgetRef ref, SkinWeather today) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    String n(num value) => number.format(value);
    final uv = today.uvMax ?? today.uvNow;

    return [
      Wrap(
        spacing: tokens.space.x8,
        runSpacing: tokens.space.x8,
        children: [
          SaafChip(
            label: l10n.weatherTemp(n(today.temperatureC)),
            tone: SaafChipTone.cornsilk,
            small: true,
          ),
          if (uv != null)
            SaafChip(
              label: l10n.weatherUv(n(uv.round())),
              tone: SaafChipTone.cornsilk,
              small: true,
            ),
          if (today.humidity case final h?)
            SaafChip(
              label: l10n.weatherHumidity(n(h)),
              tone: SaafChipTone.cornsilk,
              small: true,
            ),
          if (today.aqi case final aqi?)
            SaafChip(
              label: l10n.weatherAqi(n(aqi)),
              tone: SaafChipTone.cornsilk,
              small: true,
            ),
        ],
      ),
      for (final tip in const SkinWeatherTips()(today))
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space.x8,
          children: [
            ExcludeSemantics(
              child: Text('•', style: tokens.styles.pointCaption),
            ),
            Expanded(
              child: Text(
                _tipText(l10n, tip, n),
                style: tokens.styles.pointCaption,
              ),
            ),
          ],
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: SaafButton.text(
          label: l10n.weatherCredit,
          onPressed: () =>
              ref.read(externalLinkServiceProvider).open(_sourceUrl),
        ),
      ),
    ];
  }

  static String _tipText(
    AppLocalizations l10n,
    WeatherTip tip,
    String Function(num) n,
  ) {
    final v = n(tip.value ?? 0);
    return switch (tip.kind) {
      WeatherTipKind.uvExtreme => l10n.weatherTipUvExtreme(v),
      WeatherTipKind.uvHigh => l10n.weatherTipUvHigh(v),
      WeatherTipKind.uvModerate => l10n.weatherTipUvModerate(v),
      WeatherTipKind.uvLow => l10n.weatherTipUvLow(v),
      WeatherTipKind.smog => l10n.weatherTipSmog(v),
      WeatherTipKind.haze => l10n.weatherTipHaze(v),
      WeatherTipKind.heat => l10n.weatherTipHeat(v),
      WeatherTipKind.humid => l10n.weatherTipHumid(v),
      WeatherTipKind.dry => l10n.weatherTipDry(v),
    };
  }
}
