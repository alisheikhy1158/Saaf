import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/data/services/ai_routine_plan_json.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/no_auto_retry.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'ai_routine_providers.g.dart';

/// The skin care products the user uses now, as they typed them (kept on the
/// phone; sent to Saaf AI only when it is turned on).
@Riverpod(keepAlive: true)
class CurrentProducts extends _$CurrentProducts {
  static const max = 10;

  @override
  Future<List<String>> build() async {
    final json = await ref
        .read(settingsRepositoryProvider)
        .read(SettingNames.currentProducts);
    if (json == null) return const [];
    try {
      final list = jsonDecode(json);
      if (list is List) {
        return [
          for (final n in list)
            if (n is String) n,
        ];
      }
    } on Object {
      // A damaged entry starts the list again.
    }
    return const [];
  }

  /// False when the name is empty, already there, or the list is full.
  Future<bool> add(String name) async {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final now = await future;
    if (clean.isEmpty || now.length >= max) return false;
    if (now.any((n) => n.toLowerCase() == clean.toLowerCase())) return false;
    await _save([...now, clean]);
    return true;
  }

  Future<void> remove(String name) async {
    final now = await future;
    await _save([
      for (final n in now)
        if (n != name) n,
    ]);
  }

  Future<void> _save(List<String> names) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(
          SettingNames.currentProducts,
          names.isEmpty ? null : jsonEncode(names),
        );
    state = AsyncData(names);
  }
}

/// The routine Saaf AI researched on the web, with its verdicts on the
/// products the user uses now: null when Saaf AI is off or the quiz is not
/// answered (the routine then uses the app's own catalogue and rules). An
/// error keeps the app's routine and can be retried with [retry].
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

    final current = await ref.watch(currentProductsProvider.future);
    SkinAnalysis? analysis;
    try {
      analysis = await ref.watch(skinAnalysisProvider.future);
    } on Object {
      // No scan results: the plan still works from the quiz.
    }
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
    List<String> current,
  ) {
    List<String> names(Iterable<Enum> values) =>
        [for (final v in values) v.name]..sort();
    return [
      profile.skinType?.name,
      names(profile.concerns).join(','),
      profile.sensitivity?.name,
      profile.budget?.name,
      analysis?.scanId,
      language,
      ([...current]..sort()).join(';'),
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
