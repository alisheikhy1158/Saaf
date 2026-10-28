import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/pk_city.dart';
import 'package:saaf/presentation/providers/weather_providers.dart';
import 'package:saaf/presentation/widgets/common/city_name.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Setup: the user's city, for the daily skin weather (sun, heat, smog). A
/// list, never the phone's location; can be skipped. Then the face scan.
class ChooseCityScreen extends ConsumerStatefulWidget {
  const ChooseCityScreen({super.key});

  @override
  ConsumerState<ChooseCityScreen> createState() => _ChooseCityScreenState();
}

class _ChooseCityScreenState extends ConsumerState<ChooseCityScreen> {
  PkCity? _city;

  void _next() => context.go(SaafRoute.selfieCapture.path);

  Future<void> _continue() async {
    final city = _city;
    if (city != null) await ref.read(weatherCityProvider.notifier).choose(city);
    if (mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.chooseCity.name}'),
      topBar: SaafTopBar(
        leading: SaafTopBar.backButton(
          tooltip: l10n.back,
          onBack: () => context.go('${SaafRoute.myProducts.path}?setup=1'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x16,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.cityQuestion, style: tokens.styles.screenTitle),
          ),
          Text(
            l10n.cityWhy,
            style: context.text.bodyMedium?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          Wrap(
            spacing: space.x8,
            runSpacing: space.x8,
            children: [
              for (final city in PkCity.all)
                ChoiceChip(
                  label: Text(cityName(l10n, city)),
                  selected: _city == city,
                  onSelected: (on) => setState(() => _city = on ? city : null),
                ),
            ],
          ),
          Text(
            l10n.weatherCityNote,
            style: tokens.styles.legal.copyWith(color: tokens.textMeta),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: space.x8,
        children: [
          SaafButton.primary(
            label: l10n.scanContinue,
            onPressed: _city == null ? null : _continue,
          ),
          SaafButton.text(label: l10n.quizSkip, onPressed: _next),
        ],
      ),
    );
  }
}
