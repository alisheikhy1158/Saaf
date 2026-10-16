import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

/// What the camera area says when the camera is not running: our own camera
/// explanation (before the system dialog), "turned off", "blocked in Settings"
/// or "did not start". Every case keeps the gallery as a way forward, so the
/// app stays usable without the camera (store-compliance §1).
class ScanPermissionPanel extends StatelessWidget {
  const ScanPermissionPanel({
    required this.phase,
    required this.onContinue,
    required this.onNotNow,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onGallery,
    super.key,
  });

  final ScanPhase phase;
  final VoidCallback onContinue;
  final VoidCallback onNotNow;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;

    final (String title, String body, IconData icon) = switch (phase) {
      ScanPhase.needsRationale => (
        l10n.scanRationaleTitle,
        l10n.scanRationaleBody,
        Icons.photo_camera_outlined,
      ),
      ScanPhase.needsSettings => (
        l10n.scanSettingsTitle,
        l10n.scanSettingsBody,
        Icons.lock_outline,
      ),
      ScanPhase.failed => (
        l10n.scanFailedTitle,
        l10n.scanFailedBody,
        Icons.error_outline,
      ),
      _ => (
        l10n.scanDeniedTitle,
        l10n.scanDeniedBody,
        Icons.no_photography_outlined,
      ),
    };

    final List<Widget> buttons = switch (phase) {
      ScanPhase.needsRationale => [
        SaafButton.primary(label: l10n.scanContinue, onPressed: onContinue),
        SaafButton.text(label: l10n.scanNotNow, onPressed: onNotNow),
      ],
      ScanPhase.needsSettings => [
        SaafButton.primary(
          label: l10n.scanOpenSettings,
          onPressed: onOpenSettings,
        ),
        SaafButton.outline(label: l10n.scanGallery, onPressed: onGallery),
      ],
      _ => [
        SaafButton.primary(label: l10n.scanTryAgain, onPressed: onRetry),
        SaafButton.outline(label: l10n.scanGallery, onPressed: onGallery),
      ],
    };

    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space.x20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: box.maxHeight - tokens.space.x20 * 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.space.x12,
            children: [
              Center(
                child: SaafIconCircle(
                  icon: icon,
                  size: SaafIconCircleSize.large,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.titleLarge,
              ),
              Text(
                body,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: tokens.onInkLabel,
                ),
              ),
              if (phase == ScanPhase.needsRationale)
                Text(
                  l10n.scanPrivacyNote,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: tokens.onInkSecondary,
                  ),
                ),
              SizedBox(height: tokens.space.x4),
              ...buttons,
            ],
          ),
        ),
      ),
    );
  }
}
