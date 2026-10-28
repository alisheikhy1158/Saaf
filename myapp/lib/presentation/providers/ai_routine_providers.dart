import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/services/ai_routine_plan_json.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/owned_product.dart';
import 'package:saaf/domain/entities/product.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'ai_routine_providers.g.dart';

/// The skin care products the user uses now, as they typed them, with their
/// step (kept on the phone; sent to Saaf AI only when it is turned on).
@Riverpod(keepAlive: true)
class CurrentProducts extends _$CurrentProducts {
  static const max = 10;

  @override
  Future<List<OwnedProduct>> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.currentProducts);
    return json == null ? const [] : OwnedProduct.decodeList(json);
  }

  /// False when the name is empty, already there, or the list is full.
  Future<bool> add(String name, ProductCategory? step, {int? pricePkr}) async {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final now = await future;
    if (clean.isEmpty || now.length >= max) return false;
    if (now.any((p) => p.name.toLowerCase() == clean.toLowerCase())) {
      return false;
    }
    await _save([
      ...now,
      OwnedProduct(name: clean, step: step, pricePkr: pricePkr),
    ]);
    return true;
  }

  /// Saves the price and shelf details of the product called [name].
  Future<void> updateShelf(
    String name, {
    int? pricePkr,
    DateTime? openedOn,
    int? paoMonths,
    int? lastsWeeks,
  }) async {
    final now = await future;
    await _save([
      for (final p in now)
        if (p.name == name)
          p.withShelf(
            pricePkr: pricePkr,
            openedOn: openedOn,
            paoMonths: paoMonths,
            lastsWeeks: lastsWeeks,
          )
        else
          p,
    ]);
  }

  Future<void> remove(String name) async {
    final now = await future;
    await _save([
      for (final p in now)
        if (p.name != name) p,
    ]);
  }

  Future<void> _save(List<OwnedProduct> products) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(
          SettingNames.currentProducts,
          products.isEmpty ? null : OwnedProduct.encodeList(products),
        );
    state = AsyncData(products);
  }
}

/// The routine Saaf AI researched on the web (2–3 reviewed options per step),
/// with its verdicts on the products the user uses now: null when Saaf AI is
/// off, the quiz is not answered or no scan has been analysed yet (there is no
/// routine then: the app never suggests products nobody checked for this
/// user). An error can be retried with [retry].
///
/// Kept on the phone and only asked again when the quiz answers, the scan, the
/// current products or the language change (web research is slow and counts
/// toward the daily limit).
@Riverpod(keepAlive: true, retry: noAutoRetry)
class AiRoutinePlanController extends _$AiRoutinePlanController {
  @override
  Future<AiRoutinePlan?> build() async {
    final consent = ref.watch(aiConsentStateProvider);
    final settings = ref.read(settingsRepositoryProvider);
    if (consent != true) {
      // Stopping Saaf AI also forgets its plan.
      if (consent == false) {
        await settings.write(SettingNames.aiRoutinePlan, null);
      }
      return null;
    }

    final profile = ref.watch(skinProfileControllerProvider);
    if (profile.skinType == null && profile.concerns.isEmpty) return null;

    SkinAnalysis? analysis;
    try {
      analysis = await ref.watch(skinAnalysisProvider.future);
    } on Object {
      // Treated like no analysed scan.
    }
    // The routine is built from the face scan, never from the quiz alone.
    if (analysis == null) return null;
    final current = await ref.watch(currentProductsProvider.future);
    final language = _language(
      ref.watch(localeControllerProvider)?.languageCode,
    );

    final key = _fingerprint(profile, analysis, language, current);
    final saved = _read(await settings.read(SettingNames.aiRoutinePlan), key);
    if (saved != null) return saved;

    final result = await ref.read(planRoutineProvider)(
      profile: profile,
      currentProducts: current,
      analysis: analysis,
      languageCode: language,
    );
    final plan = result.valueOrNull;
    if (plan == null) throw result.failureOrNull!;
    await settings.write(
      SettingNames.aiRoutinePlan,
      jsonEncode({'key': key, 'plan': AiRoutinePlanJson.encode(plan)}),
    );
    return plan;
  }

  /// Asks Saaf AI again after a failure.
  void retry() => ref.invalidateSelf();

  static String _language(String? chosen) {
    final code = chosen ?? PlatformDispatcher.instance.locale.languageCode;
    return code == 'ur' ? 'ur' : 'en';
  }

  /// What the plan depends on. Stays on the phone.
  static String _fingerprint(
    SkinProfile profile,
    SkinAnalysis? analysis,
    String language,
    List<OwnedProduct> current,
  ) {
    List<String> names(Iterable<Enum> values) =>
        [for (final v in values) v.name]..sort();
    return [
      // v2: several options per step (older single-pick plans are asked again).
      'v2',
      profile.skinType?.name,
      names(profile.concerns).join(','),
      profile.sensitivity?.name,
      profile.budget?.name,
      analysis?.scanId,
      language,
      ([
        for (final p in current) '${p.name}:${p.step?.name}:${p.pricePkr}',
      ]..sort()).join(';'),
    ].join('|');
  }

  static AiRoutinePlan? _read(String? json, String key) {
    if (json == null) return null;
    try {
      final data = jsonDecode(json);
      if (data case {
        'key': final String savedKey,
        'plan': final Object plan,
      } when savedKey == key) {
        return AiRoutinePlanJson.decode(plan);
      }
    } on Object {
      // A damaged entry is simply asked for again.
    }
    return null;
  }
}

/// Which of Saaf AI's options the user chose for each step (step key → product
/// id, see `pickSlotKey`). A step with no choice uses the best option the
/// safety answers allow. Kept on the phone.
@Riverpod(keepAlive: true)
class RoutineChoices extends _$RoutineChoices {
  @override
  Future<Map<String, String>> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.routineChoices);
    if (json == null) return const {};
    try {
      final data = jsonDecode(json);
      if (data is! Map<String, Object?>) return const {};
      return {
        for (final MapEntry(:key, :value) in data.entries)
          if (value is String) key: value,
      };
    } on Object {
      return const {};
    }
  }

  Future<void> choose(String slot, String productId) async {
    final now = {...await future, slot: productId};
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.routineChoices, jsonEncode(now));
    state = AsyncData(now);
  }
}
