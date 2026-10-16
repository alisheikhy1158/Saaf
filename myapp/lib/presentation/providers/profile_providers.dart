import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/usecases/delete_account.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/check_in_providers.dart';
import 'package:saaf/presentation/providers/completed_scan.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';
import 'package:saaf/presentation/providers/home_providers.dart';
import 'package:saaf/presentation/providers/onboarding_status.dart';
import 'package:saaf/presentation/providers/pending_sign_in.dart';
import 'package:saaf/presentation/providers/progress_providers.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';

part 'profile_providers.g.dart';

/// When to remind the user of their routines. In memory for now (database in
/// Phase 7, notifications with the permission flow).
@Riverpod(keepAlive: true)
class ReminderSettingsController extends _$ReminderSettingsController {
  @override
  ReminderSettings build() => const ReminderSettings();

  void set(ReminderSettings settings) => state = settings;
}

/// Light, dark, or whatever the phone uses.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
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
    if (result.isOk) _wipeLocalData();
    if (ref.mounted) state = false;
    return result;
  }

  /// Back to a fresh install, except for the language and appearance choices.
  void _wipeLocalData() {
    ref
      ..invalidate(skinProfileControllerProvider)
      ..invalidate(skinProfileRepositoryProvider)
      ..invalidate(completedScanProvider)
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
