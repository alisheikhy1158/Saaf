import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/product_picks.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/routine_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'product_picks_providers.g.dart';

/// Where the last picks are kept on the phone (with what they were for), so
/// Saaf AI is only asked again when the quiz answers, the scan or the
/// language change.
const aiProductPicksSetting = 'aiProductPicks';

/// The products Saaf AI chose for the routine: null when the user has not
/// turned Saaf AI on or has not answered the quiz yet (the routine then uses
/// the app's own rules). An error leaves the rule-based routine in place and
/// can be retried with [AiProductPicks.retry].
@Riverpod(keepAlive: true, retry: noAutoRetry)
class AiProductPicks extends _$AiProductPicks {
  @override
  Future<ProductPicks?> build() async {
    final consent = ref.watch(aiConsentStateProvider);
    final settings = ref.read(settingsRepositoryProvider);
    if (consent != true) {
      // Stopping Saaf AI also forgets what it chose.
      if (consent == false) await settings.write(aiProductPicksSetting, null);
      return null;
    }

    final profile = ref.watch(skinProfileControllerProvider);
    if (profile.skinType == null && profile.concerns.isEmpty) return null;

    final catalog = await ref.watch(productCatalogProvider).all();
    SkinAnalysis? analysis;
    try {
      analysis = await ref.watch(skinAnalysisProvider.future);
    } on Object {
      // No scan results: the picks still work from the quiz.
    }
    final language = _language(
      ref.watch(localeControllerProvider)?.languageCode,
    );

    final key = _fingerprint(profile, analysis, language, catalog);
    final saved = _read(await settings.read(aiProductPicksSetting), key);
    if (saved != null) return saved;

    final result = await ref.read(pickProductsProvider)(
      profile: profile,
      catalog: catalog,
      analysis: analysis,
      languageCode: language,
    );
    final picks = result.valueOrNull;
    if (picks == null) throw result.failureOrNull!;
    await settings.write(aiProductPicksSetting, _write(picks, key));
    return picks;
  }

  /// Asks Saaf AI again after a failure.
  void retry() => ref.invalidateSelf();

  static String _language(String? chosen) {
    final code = chosen ?? PlatformDispatcher.instance.locale.languageCode;
    return code == 'ur' ? 'ur' : 'en';
  }

  /// What the picks depend on. Stays on the phone (it includes the safety
  /// answers, which change which products are allowed).
  static String _fingerprint(
    SkinProfile profile,
    SkinAnalysis? analysis,
    String language,
    List<Product> catalog,
  ) {
    List<String> names(Iterable<Enum> values) =>
        [for (final v in values) v.name]..sort();
    return [
      profile.skinType?.name,
      names(profile.concerns).join(','),
      profile.sensitivity?.name,
      profile.budget?.name,
      profile.safetyFlags == null ? '-' : names(profile.safetyFlags!).join(','),
      analysis?.scanId,
      language,
      Object.hashAll([for (final p in catalog) '${p.id}:${p.pricePkr}']),
    ].join('|');
  }

  static ProductPicks? _read(String? json, String key) {
    if (json == null) return null;
    try {
      final data = jsonDecode(json);
      if (data case {
        'key': final String savedKey,
        'summary': final String summary,
        'picks': final List<Object?> list,
      } when savedKey == key) {
        final picks = [
          for (final item in list)
            if (item case {
              'id': final String id,
              'reason': final String reason,
            })
              ProductPick(productId: id, reason: reason),
        ];
        if (picks.isNotEmpty) {
          return ProductPicks(summary: summary, picks: picks);
        }
      }
    } on Object {
      // A damaged entry is simply asked for again.
    }
    return null;
  }

  static String _write(ProductPicks picks, String key) => jsonEncode({
    'key': key,
    'summary': picks.summary,
    'picks': [
      for (final p in picks.picks) {'id': p.productId, 'reason': p.reason},
    ],
  });
}
