import 'dart:ui' show AppLifecycleState, Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/env.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/data/services/plugin_notification_permission_service.dart';
import 'package:saaf/data/services/plugin_reminder_scheduler.dart';
import 'package:saaf/data/services/web/fake_notification_permission_service.dart';
import 'package:saaf/domain/entities/notification_permission.dart';
import 'package:saaf/domain/services/notification_permission_service.dart';
import 'package:saaf/domain/services/reminder_scheduler.dart';
import 'package:saaf/domain/usecases/notification_access.dart';
import 'package:saaf/domain/usecases/sync_reminders.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';

part 'notification_providers.g.dart';

/// Chrome and `FAKE_CAMERA` demos have no phone to notify: permission and
/// scheduling are pretend there.
bool get _pretend => kIsWeb || Env.fakeCamera;

@Riverpod(keepAlive: true)
NotificationPermissionService notificationPermissionService(Ref ref) => _pretend
    ? FakeNotificationPermissionService(NotificationPermission.denied)
    : const PluginNotificationPermissionService();

@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) =>
    _pretend ? FakeReminderScheduler() : PluginReminderScheduler();

@Riverpod(keepAlive: true)
NotificationAccess notificationAccess(Ref ref) =>
    NotificationAccess(ref.watch(notificationPermissionServiceProvider));

@Riverpod(keepAlive: true)
SyncReminders syncReminders(Ref ref) => SyncReminders(
  scheduler: ref.watch(reminderSchedulerProvider),
  permissions: ref.watch(notificationPermissionServiceProvider),
);

/// The notification words in the language the app is showing: the chosen one,
/// else the phone's, else English.
ReminderTexts reminderTextsFor(Locale? chosen) {
  final wanted = chosen ?? PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == wanted.languageCode,
  );
  final l10n = lookupAppLocalizations(supported ? wanted : const Locale('en'));
  return ReminderTexts(
    morningTitle: l10n.reminderNotificationMorningTitle,
    morningBody: l10n.reminderNotificationMorningBody,
    nightTitle: l10n.reminderNotificationNightTitle,
    nightBody: l10n.reminderNotificationNightBody,
  );
}

/// Keeps the phone's scheduled reminders in step with the saved settings.
/// Runs again when the times, the switches or the language change, and when
/// the app comes back to the front (the user may have allowed notifications in
/// the phone's Settings). Watched by the root widget. True when reminders are
/// scheduled.
@Riverpod(keepAlive: true)
Future<bool> reminderSync(Ref ref) {
  final settings = ref.watch(reminderSettingsControllerProvider);
  final locale = ref.watch(localeControllerProvider);
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state == AppLifecycleState.resumed && ref.mounted) {
        ref.invalidateSelf();
      }
    },
  );
  ref.onDispose(listener.dispose);
  return ref.read(syncRemindersProvider)(settings, reminderTextsFor(locale));
}
