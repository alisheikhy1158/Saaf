import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/reminder_settings.dart';
import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_profile.dart';
import 'package:saaf/domain/entities/skin_type.dart';
import 'package:saaf/domain/usecases/notification_access.dart';
import 'package:saaf/presentation/providers/auth_providers.dart';
import 'package:saaf/presentation/providers/locale_controller.dart';
import 'package:saaf/presentation/providers/notification_providers.dart';
import 'package:saaf/presentation/providers/profile_providers.dart';
import 'package:saaf/presentation/providers/skin_profile_providers.dart';
import 'package:saaf/presentation/providers/subscription_providers.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_ink_card.dart';
import 'package:saaf/presentation/widgets/common/saaf_main_nav.dart';
import 'package:saaf/presentation/widgets/common/saaf_overline.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_segmented_control.dart';
import 'package:saaf/presentation/widgets/common/saaf_settings_group.dart';

/// Figma 14 Profile & privacy: who you are, your plan, the answers behind your
/// routine, privacy choices (including deleting the account, store requirement
/// A-1) and the app settings (language, appearance, legal pages, log out).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final space = tokens.space;
    final locale = Localizations.localeOf(context);
    final profile = ref.watch(skinProfileControllerProvider);
    final session = ref.watch(authSessionControllerProvider);
    final isPro = ref.watch(proStatusProvider);
    final reminders = ref.watch(reminderSettingsControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    final name = session?.displayName;
    final phone = session?.phoneE164;
    final title =
        name ??
        (phone != null && phone.length >= 4
            ? l10n.profilePhoneFallback(phone.substring(phone.length - 4))
            : l10n.profileNameFallback);
    final initial = (name ?? l10n.profileNameFallback).characters.first
        .toUpperCase();

    final budgetLimit = profile.budget?.maxMonthlyPkr;
    final budgetValue = profile.budget == null
        ? l10n.profileValueNotSet
        : budgetLimit == null
        ? l10n.profileValueNoLimit
        : l10n.priceRs(
            NumberFormat.decimalPattern(locale.toString()).format(budgetLimit),
          );

    final language = locale.languageCode == 'ur'
        ? l10n.profileLangUrdu
        : l10n.profileLangEnglish;
    final appearance = switch (themeMode) {
      ThemeMode.system => l10n.profileThemeSystem,
      ThemeMode.light => l10n.profileThemeLight,
      ThemeMode.dark => l10n.profileThemeDark,
    };

    return SaafMainNav(
      current: SaafMainTab.profile,
      child: SaafScaffold(
        key: ValueKey('screen-${SaafRoute.profile.name}'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: space.x8),
            Semantics(
              header: true,
              child: Text(
                l10n.profileTitle,
                style: context.text.headlineMedium,
              ),
            ),
            SizedBox(height: space.x16),
            _Identity(
              initial: initial,
              name: title,
              caption: _skinLine(l10n, profile),
            ),
            SizedBox(height: space.x16),
            _ProCard(isPro: isPro),
            SizedBox(height: space.sectionGapSmall),
            SaafOverline(l10n.profileSectionRoutine),
            SizedBox(height: space.x8),
            SaafSettingsGroup(
              rows: [
                SaafSettingsRow(
                  icon: Icons.water_drop_outlined,
                  title: l10n.profileRowSkin,
                  value: _skinValue(l10n, profile),
                  onTap: () => context.push(SaafRoute.skinQuiz.path),
                ),
                SaafSettingsRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.profileRowBudget,
                  value: budgetValue,
                  onTap: () => context.push('${SaafRoute.skinQuiz.path}/5'),
                ),
                SaafSettingsRow(
                  icon: Icons.notifications_none,
                  title: l10n.profileRowReminders,
                  value: reminders.summary(l10n.profileValueOff),
                  onTap: () => _showSheet(context, const _RemindersSheet()),
                ),
                SaafSettingsRow(
                  icon: Icons.language,
                  title: l10n.profileRowLanguage,
                  value: language,
                  onTap: () => _showSheet(context, const _LanguageSheet()),
                ),
              ],
            ),
            SizedBox(height: space.sectionGapSmall),
            SaafOverline(l10n.profileSectionPrivacy),
            SizedBox(height: space.x8),
            SaafSettingsGroup(
              rows: [
                SaafSettingsRow(
                  icon: Icons.cloud_outlined,
                  title: l10n.profileRowBackup,
                  value: l10n.profileValueOff,
                  onTap: () => _showSheet(context, const _BackupSheet()),
                ),
                SaafSettingsRow(
                  icon: Icons.delete_outline,
                  title: l10n.profileRowDelete,
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
            SizedBox(height: space.sectionGapSmall),
            SaafOverline(l10n.profileSectionApp),
            SizedBox(height: space.x8),
            SaafSettingsGroup(
              rows: [
                SaafSettingsRow(
                  icon: Icons.contrast,
                  title: l10n.profileRowAppearance,
                  value: appearance,
                  onTap: () => _showSheet(context, const _AppearanceSheet()),
                ),
                SaafSettingsRow(
                  icon: Icons.description_outlined,
                  title: l10n.termsTitle,
                  onTap: () => context.push(SaafRoute.terms.path),
                ),
                SaafSettingsRow(
                  icon: Icons.shield_outlined,
                  title: l10n.privacyPolicyTitle,
                  onTap: () => context.push(SaafRoute.privacyPolicy.path),
                ),
                SaafSettingsRow(
                  icon: Icons.logout,
                  title: l10n.profileRowLogout,
                  onTap: () => _confirmLogOut(context, ref),
                ),
              ],
            ),
            SizedBox(height: space.x16),
          ],
        ),
      ),
    );
  }

  /// "Combination skin · Acne-prone", or null when nothing is known.
  static String? _skinLine(AppLocalizations l10n, SkinProfile profile) {
    final type = _typeTitle(l10n, profile.skinType);
    final concern = profile.concerns.firstOrNull;
    final parts = [
      if (type != null) l10n.profileSkinType(type),
      if (concern != null)
        concern == SkinConcern.acne
            ? l10n.productAcneProne
            : _capitalised(_concernName(l10n, concern)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// "Oily, dark spots".
  static String _skinValue(AppLocalizations l10n, SkinProfile profile) {
    final type = _typeTitle(l10n, profile.skinType);
    final parts = [
      ?type,
      for (final concern in profile.concerns) _concernName(l10n, concern),
    ];
    return parts.isEmpty ? l10n.profileValueNotSet : parts.join(', ');
  }

  static String? _typeTitle(AppLocalizations l10n, SkinType? type) =>
      switch (type) {
        SkinType.oily => l10n.skinTypeOilyTitle,
        SkinType.dry => l10n.skinTypeDryTitle,
        SkinType.combination => l10n.skinTypeCombinationTitle,
        SkinType.normal => l10n.skinTypeNormalTitle,
        SkinType.notSure || null => null,
      };

  static String _concernName(AppLocalizations l10n, SkinConcern concern) =>
      switch (concern) {
        SkinConcern.darkSpots => l10n.concernDarkSpots,
        SkinConcern.acne => l10n.concernAcne,
        SkinConcern.oiliness => l10n.concernOiliness,
        SkinConcern.dryness => l10n.concernDryness,
        SkinConcern.unevenTone => l10n.concernUnevenTone,
      };

  static String _capitalised(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  // ── Dialogs and sheets ───────────────────────────────────────────────────

  static Future<void> _showSheet(BuildContext context, Widget sheet) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => sheet,
      );

  Future<void> _confirmLogOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(accountControllerProvider.notifier).logOut();
    if (context.mounted) context.go(SaafRoute.welcome.path);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(accountControllerProvider.notifier)
        .deleteAccount();
    if (!context.mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) {
      context.go(SaafRoute.welcome.path);
      return;
    }
    final message = failure == const UnknownFailure('requires-recent-login')
        ? l10n.deleteFailedRecent
        : l10n.deleteFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The avatar with the name and a line about the skin.
class _Identity extends StatelessWidget {
  const _Identity({
    required this.initial,
    required this.name,
    required this.caption,
  });

  final String initial;
  final String name;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Row(
      spacing: tokens.space.benefitGap,
      children: [
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: tokens.size.avatar,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.sage,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: tokens.styles.avatarInitial.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space.x2,
            children: [
              Text(name, style: context.text.titleMedium),
              if (caption != null)
                Text(
                  caption!,
                  style: tokens.styles.meta.copyWith(color: tokens.textCaption),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "You're on the free plan" with Go Pro, or the thank-you for Pro users.
class _ProCard extends StatelessWidget {
  const _ProCard({required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    return SaafInkCard(
      radius: tokens.radius.r20,
      padding: EdgeInsetsDirectional.all(tokens.space.x16),
      child: Row(
        spacing: tokens.space.rowGap,
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.space.x2,
                children: [
                  Text(
                    isPro ? l10n.profilePlanPro : l10n.profilePlanFree,
                    style: tokens.styles.listTitle.copyWith(
                      color: context.colors.onInverseSurface,
                    ),
                  ),
                  Text(
                    isPro ? l10n.profilePlanProBody : l10n.profilePlanFreeBody,
                    style: tokens.styles.legal.copyWith(
                      color: tokens.onInkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: isPro ? l10n.profileManage : l10n.profileGoPro,
            excludeSemantics: true,
            onTap: () => context.push(SaafRoute.paywall.path),
            child: InkWell(
              onTap: () => context.push(SaafRoute.paywall.path),
              borderRadius: BorderRadius.circular(tokens.radius.r18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: tokens.size.minTouchTarget,
                  minWidth: tokens.size.minTouchTarget,
                ),
                child: Center(
                  widthFactor: 1,
                  child: SaafChip(
                    label: isPro ? l10n.profileManage : l10n.profileGoPro,
                    tone: SaafChipTone.sage,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The frame every bottom sheet shares: a title, the content and a Done button.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          tokens.space.gutter,
          tokens.space.x8,
          tokens.space.gutter,
          tokens.space.pageBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.space.x16,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: context.text.titleLarge),
            ),
            ...children,
            SaafButton.primary(
              label: l10n.commonDone,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return _SheetFrame(
      title: l10n.languageTitle,
      children: [
        SaafSegmentedControl(
          segments: [
            SaafSegment(label: l10n.profileLangEnglish, icon: Icons.language),
            SaafSegment(label: l10n.profileLangUrdu, icon: Icons.language),
          ],
          selectedIndex: isUrdu ? 1 : 0,
          onChanged: (i) => ref
              .read(localeControllerProvider.notifier)
              .setLocale(Locale(i == 1 ? 'ur' : 'en')),
          semanticLabel: l10n.languageSemantics,
        ),
      ],
    );
  }
}

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeControllerProvider);
    const modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

    return _SheetFrame(
      title: l10n.appearanceTitle,
      children: [
        SaafSegmentedControl(
          segments: [
            SaafSegment(label: l10n.profileThemeSystem),
            SaafSegment(label: l10n.profileThemeLight),
            SaafSegment(label: l10n.profileThemeDark),
          ],
          selectedIndex: modes.indexOf(mode),
          onChanged: (i) =>
              ref.read(themeModeControllerProvider.notifier).set(modes[i]),
          semanticLabel: l10n.appearanceTitle,
        ),
      ],
    );
  }
}

class _BackupSheet extends StatelessWidget {
  const _BackupSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SheetFrame(
      title: l10n.backupTitle,
      children: [
        Text(
          l10n.backupBody,
          style: context.text.bodyLarge?.copyWith(
            color: context.saaf.textLabel,
          ),
        ),
      ],
    );
  }
}

class _RemindersSheet extends ConsumerStatefulWidget {
  const _RemindersSheet();

  @override
  ConsumerState<_RemindersSheet> createState() => _RemindersSheetState();
}

class _RemindersSheetState extends ConsumerState<_RemindersSheet> {
  /// What the phone says about notifications (null until it has answered).
  NotificationAccessOutcome? _access;

  @override
  void initState() {
    super.initState();
    ref.read(notificationAccessProvider).check().then((outcome) {
      if (mounted) setState(() => _access = outcome);
    });
  }

  /// Our explanation first, then the system dialog; true when reminders may be
  /// sent. A refusal never blocks the app: the sheet just explains (store-
  /// compliance §1).
  Future<bool> _ensureAccess() async {
    final access = ref.read(notificationAccessProvider);
    var outcome = await access.check();
    if (outcome == NotificationAccessOutcome.needsRationale) {
      if (!mounted) return false;
      final go = await _askWhy();
      if (go != true) {
        if (mounted) setState(() => _access = outcome);
        return false;
      }
      outcome = await access.request();
    }
    if (!mounted) return false;
    setState(() => _access = outcome);
    return outcome == NotificationAccessOutcome.granted;
  }

  Future<bool?> _askWhy() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.remindersRationaleTitle),
        content: Text(l10n.remindersRationaleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.scanNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.scanContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _switchTo(
    bool on,
    ReminderSettings Function(bool) change,
  ) async {
    if (on && !await _ensureAccess()) return;
    ref.read(reminderSettingsControllerProvider.notifier).set(change(on));
  }

  Future<void> _allow() async {
    if (await _ensureAccess()) ref.invalidate(reminderSyncProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final settings = ref.watch(reminderSettingsControllerProvider);
    final controller = ref.read(reminderSettingsControllerProvider.notifier);

    Future<void> pick(
      ReminderTime current,
      void Function(ReminderTime) set,
    ) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      );
      if (picked != null) set(ReminderTime(picked.hour, picked.minute));
    }

    Widget row({
      required String name,
      required bool on,
      required ReminderTime time,
      required ValueChanged<bool> onChanged,
      required VoidCallback onPickTime,
    }) => Row(
      spacing: tokens.space.rowGap,
      children: [
        Expanded(child: Text(name, style: tokens.styles.rowTitle)),
        Tooltip(
          message: l10n.remindersChange(name),
          child: InkWell(
            onTap: on ? onPickTime : null,
            borderRadius: BorderRadius.circular(tokens.radius.r18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: tokens.size.minTouchTarget,
                minWidth: tokens.size.minTouchTarget,
              ),
              child: Center(
                widthFactor: 1,
                child: SaafChip(label: time.text, tone: SaafChipTone.sageTint),
              ),
            ),
          ),
        ),
        Switch(value: on, onChanged: onChanged),
      ],
    );

    final access = _access;
    final anyOn = settings.morningOn || settings.nightOn;
    final blocked = access == NotificationAccessOutcome.needsSettings;
    final needsAllowing =
        access != null && access != NotificationAccessOutcome.granted;
    final showNotice = needsAllowing && (anyOn || blocked);

    return _SheetFrame(
      title: l10n.remindersTitle,
      children: [
        row(
          name: l10n.remindersMorning,
          on: settings.morningOn,
          time: settings.morning,
          onChanged: (v) =>
              _switchTo(v, (on) => settings.copyWith(morningOn: on)),
          onPickTime: () => pick(
            settings.morning,
            (t) => controller.set(settings.copyWith(morning: t)),
          ),
        ),
        row(
          name: l10n.remindersNight,
          on: settings.nightOn,
          time: settings.night,
          onChanged: (v) =>
              _switchTo(v, (on) => settings.copyWith(nightOn: on)),
          onPickTime: () => pick(
            settings.night,
            (t) => controller.set(settings.copyWith(night: t)),
          ),
        ),
        if (showNotice) ...[
          Text(switch (access) {
            NotificationAccessOutcome.needsSettings =>
              l10n.remindersBlockedNote,
            NotificationAccessOutcome.denied => l10n.remindersDeniedNote,
            _ => l10n.remindersRationaleBody,
          }, style: context.text.bodyMedium?.copyWith(color: tokens.textLabel)),
          SaafButton.outline(
            label: blocked
                ? l10n.scanOpenSettings
                : l10n.remindersRationaleTitle,
            onPressed: blocked
                ? () => ref.read(notificationAccessProvider).openSettings()
                : _allow,
          ),
        ],
        Text(
          l10n.remindersNote,
          style: tokens.styles.legal.copyWith(color: tokens.textMeta),
        ),
      ],
    );
  }
}
