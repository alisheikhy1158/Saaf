import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/profile_details.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/usecases/ai_consent.dart';
import 'package:saaf/domain/usecases/delete_account.dart';
import 'package:saaf/presentation/providers/ai_chat_controller.dart';
import 'package:saaf/presentation/providers/ai_providers.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/check_in_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/database_providers.dart';
import 'package:saaf/presentation/providers/home_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/settings_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'profile_providers.g.dart';

/// When to remind the user of their routines. In memory for now (database in
/// Phase 7, notifications with the permission flow).
@Riverpod(keepAlive: true)
class ReminderSettingsController extends _$ReminderSettingsController {
  bool _changed = false;

  @override
  ReminderSettings build() {
    ref.read(settingsRepositoryProvider).read(SettingNames.reminders).then((
      text,
    ) {
      if (ref.mounted && !_changed) state = ReminderSettings.decode(text);
    });
    return const ReminderSettings();
  }

  void set(ReminderSettings settings) {
    _changed = true;
    state = settings;
    ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.reminders, settings.encode());
  }
}

/// Light, dark, or whatever the phone uses.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  bool _changed = false;

  @override
  ThemeMode build() {
    ref.read(settingsRepositoryProvider).read(SettingNames.theme).then((name) {
      final saved = ThemeMode.values.where((m) => m.name == name).firstOrNull;
      if (ref.mounted && !_changed && saved != null) state = saved;
    });
    return ThemeMode.system;
  }

  void set(ThemeMode mode) {
    _changed = true;
    state = mode;
    ref.read(settingsRepositoryProvider).write(SettingNames.theme, mode.name);
  }
}

/// The name and age the user added on Profile (stored only on this phone).
@Riverpod(keepAlive: true)
class ProfileDetailsController extends _$ProfileDetailsController {
  bool _changed = false;

  @override
  ProfileDetails build() {
    final settings = ref.read(settingsRepositoryProvider);
    Future.wait([
      settings.read(SettingNames.name),
      settings.read(SettingNames.age),
    ]).then((saved) {
      if (!ref.mounted || _changed) return;
      state = ProfileDetails(
        name: saved[0],
        age: ProfileDetails.ageFromStored(saved[1]),
      );
    });
    return const ProfileDetails();
  }

  /// Saves [name] and [age] (either can be null to leave it out).
  void set({String? name, int? age}) {
    _changed = true;
    state = ProfileDetails(name: name, age: age);
    ref.read(settingsRepositoryProvider)
      ..write(SettingNames.name, name)
      ..write(SettingNames.age, age?.toString());
  }
}

@riverpod
DeleteAccount deleteAccountUseCase(Ref ref) => DeleteAccount(
  auth: ref.watch(authRepositoryProvider),
  photos: ref.watch(photoStoreProvider),
);

/// Log out and delete account. Kept alive so an action finishes even if the
/// screen that started it is gone.
@Riverpod(keepAlive: true)
class AccountController extends _$AccountController {
  /// True while an account action is running.
  @override
  bool build() => false;

  Future<void> logOut() async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      if (ref.mounted) state = false;
    }
    ref.read(authSessionControllerProvider.notifier).set(null);
  }

  /// Deletes the account, then everything Saaf keeps on this phone. If the
  /// account cannot be deleted nothing is wiped.
  Future<Result<void>> deleteAccount() async {
    state = true;
    final scanIds = {
      for (final scan in ref.read(scanHistoryProvider)) scan.id,
      ?ref.read(completedScanProvider)?.id,
    }.toList();

    final result = await ref.read(deleteAccountUseCaseProvider)(scanIds);
    if (result.isOk) await _wipeLocalData();
    if (ref.mounted) state = false;
    return result;
  }

  /// Back to a fresh install, except for the language and appearance choices.
  Future<void> _wipeLocalData() async {
    // The database first, so nothing is read back after the reset below.
    await ref.read(appDatabaseProvider)?.wipe();
    await ref.read(settingsRepositoryProvider).write(SettingNames.name, null);
    await ref.read(settingsRepositoryProvider).write(SettingNames.age, null);
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.currentProducts, null);
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.aiRoutinePlan, null);
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.aiSkinEstimates, null);
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingNames.autoAnalyseScans, null);
    for (final name in [
      SettingNames.weatherCity,
      SettingNames.introduction,
      SettingNames.lifeEvent,
      SettingNames.ramadanMode,
    ]) {
      await ref.read(settingsRepositoryProvider).write(name, null);
    }
    await ref
        .read(settingsRepositoryProvider)
        .write(AiConsent.settingName, null);
    ref
      ..invalidate(profileDetailsControllerProvider)
      ..invalidate(aiConsentStateProvider)
      ..invalidate(aiChatControllerProvider)
      ..invalidate(skinProfileControllerProvider)
      ..invalidate(skinProfileRepositoryProvider)
      ..invalidate(completedScanProvider)
      ..invalidate(scanHistoryRepositoryProvider)
      ..invalidate(onboardingRepositoryProvider)
      ..invalidate(scanHistoryProvider)
      ..invalidate(checkInRepositoryProvider)
      ..invalidate(routineLogRepositoryProvider)
      ..invalidate(consentRepositoryProvider)
      ..invalidate(reminderSettingsControllerProvider)
      ..invalidate(pendingSignInProvider)
      ..invalidate(consentStatusProvider)
      ..invalidate(quizDoneProvider);
    ref.read(authSessionControllerProvider.notifier).set(null);
  }
}
