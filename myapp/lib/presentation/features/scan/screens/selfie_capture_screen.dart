import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/router/saaf_route.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/capture_quality.dart';
import 'package:saaf/presentation/features/scan/controllers/scan_controller.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/features/scan/widgets/pose_text.dart';
import 'package:saaf/presentation/features/scan/widgets/scan_permission_panel.dart';
import 'package:saaf/presentation/features/scan/widgets/scan_pose_stepper.dart';
import 'package:saaf/presentation/features/scan/widgets/scan_quality_chips.dart';
import 'package:saaf/presentation/features/scan/widgets/scan_viewfinder.dart';
import 'package:saaf/presentation/widgets/common/saaf_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_camera_controls.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';
import 'package:saaf/presentation/widgets/common/saaf_dark_scope.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/presentation/widgets/common/saaf_scaffold.dart';
import 'package:saaf/presentation/widgets/common/saaf_top_bar.dart';

/// Figma 06 Selfie capture, taken three times: front, left cheek, right cheek.
/// Always dark. Without camera permission the camera area explains why and
/// offers the gallery, so the app stays usable (store-compliance §1).
class SelfieCaptureScreen extends StatelessWidget {
  const SelfieCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => const SaafDarkScope(child: _ScanView());
}

class _ScanView extends ConsumerWidget {
  const _ScanView();

  static const _panelPhases = {
    ScanPhase.needsRationale,
    ScanPhase.denied,
    ScanPhase.needsSettings,
    ScanPhase.failed,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);

    ref.listen(scanControllerProvider.select((s) => s.phase), (_, phase) {
      if (phase == ScanPhase.done) {
        context.go(SaafRoute.analysisResults.path);
      }
    });

    void leave() => context.go(SaafRoute.home.path);

    final showsPanel = _panelPhases.contains(state.phase);
    final isLive = state.phase == ScanPhase.live;
    final isReviewing =
        state.phase == ScanPhase.reviewing || state.phase == ScanPhase.saving;
    final isLast = state.session.isComplete;

    return SaafScaffold(
      key: ValueKey('screen-${SaafRoute.selfieCapture.name}'),
      topBar: SaafTopBar(
        title: l10n.scanTitle,
        leading: SaafIconButton(
          icon: Icons.close,
          tooltip: l10n.scanClose,
          onDark: true,
          onPressed: leave,
        ),
        trailing: SaafIconButton(
          icon: Icons.wb_sunny_outlined,
          tooltip: l10n.scanLightToggle,
          onDark: true,
          onPressed: controller.toggleFillLight,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space.x14,
        children: [
          ScanPoseStepper(
            current: state.pose,
            taken: state.session.photos.keys.toSet(),
            onSelect: controller.selectPose,
          ),
          Center(child: _HintChip(state: state)),
          _Frame(
            state: state,
            panel: showsPanel
                ? ScanPermissionPanel(
                    phase: state.phase,
                    onContinue: controller.continueFromRationale,
                    onNotNow: leave,
                    onRetry: controller.retry,
                    onOpenSettings: controller.openSettings,
                    onGallery: controller.pickFromGallery,
                  )
                : null,
          ),
          if (isLive) ScanQualityChips(quality: state.quality),
          _StatusLine(state: state),
        ],
      ),
      bottom: showsPanel
          ? null
          : isReviewing
          ? _ReviewButtons(
              isLast: isLast,
              isSaving: state.phase == ScanPhase.saving,
              onRetake: controller.retake,
              onAccept: controller.accept,
            )
          : SaafCameraControls(
              galleryLabel: l10n.scanGallery,
              shutterLabel: l10n.scanShutter,
              flipLabel: l10n.scanFlip,
              onGallery: isLive ? controller.pickFromGallery : null,
              onShutter: isLive ? controller.capture : null,
              onFlip: isLive && state.canFlip ? controller.flip : null,
            ),
    );
  }
}

/// The advice chip when the light is wrong, otherwise what to do for this photo.
class _HintChip extends StatelessWidget {
  const _HintChip({required this.state});

  final ScanState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final advice = state.phase == ScanPhase.live
        ? switch (state.quality.advice) {
            LightAdvice.tooBright => l10n.scanAdviceTooBright,
            LightAdvice.tooDark => l10n.scanAdviceTooDark,
            LightAdvice.none => null,
          }
        : null;

    return advice != null
        ? SaafChip(
            label: advice,
            icon: Icons.wb_sunny_outlined,
            tone: SaafChipTone.strong,
          )
        : SaafChip(
            label: state.pose.instruction(l10n),
            icon: Icons.face_outlined,
            tone: SaafChipTone.onDark,
          );
  }
}

/// The viewfinder, sized from the space the rest of the screen leaves, with the
/// optional light frame around it.
class _Frame extends StatelessWidget {
  const _Frame({required this.state, required this.panel});

  final ScanState state;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final scan = tokens.scan;
    final media = MediaQuery.of(context);
    final ratio = scan.designWidth / scan.designHeight;
    final room =
        media.size.height - media.padding.vertical - scan.reservedHeight;
    final wantedHeight = room.clamp(scan.minHeight, scan.designHeight);

    return LayoutBuilder(
      builder: (context, box) {
        final width = math.min(box.maxWidth, wantedHeight * ratio);
        final frame = state.fillLight ? tokens.space.x8 : 0.0;
        final inner = width - frame * 2;

        Widget viewfinder = SizedBox(
          width: inner,
          height: inner / ratio,
          child: ScanViewfinder(state: state, panel: panel),
        );
        if (state.fillLight) {
          viewfinder = DecoratedBox(
            key: const ValueKey('scan-light-frame'),
            decoration: BoxDecoration(
              color: context.colors.onSurface,
              borderRadius: BorderRadius.circular(tokens.radius.r32),
            ),
            child: Padding(padding: EdgeInsets.all(frame), child: viewfinder),
          );
        }
        return Center(child: viewfinder);
      },
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.state});

  final ScanState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.saaf;
    final failure = state.failure;

    final (String? text, bool isError) = switch ((state.phase, failure)) {
      (ScanPhase.reviewing, final Failure _) => (l10n.scanSaveFailed, true),
      (ScanPhase.live, UnknownFailure(message: 'pick')) => (
        l10n.scanPickFailed,
        true,
      ),
      (ScanPhase.live, final Failure _) => (l10n.scanCaptureFailed, true),
      (ScanPhase.live, _) => (
        state.countdown != null
            ? l10n.scanStatusCountdown(state.countdown!)
            : l10n.scanStatusManual,
        false,
      ),
      (ScanPhase.reviewing, _) => (l10n.scanReviewQuestion, false),
      (ScanPhase.saving, _) => (l10n.scanSaving, false),
      _ => (null, false),
    };
    if (text == null) return const SizedBox.shrink();

    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.text.bodyMedium?.copyWith(
        color: isError ? context.colors.error : tokens.onInkLabel,
      ),
    );
  }
}

class _ReviewButtons extends StatelessWidget {
  const _ReviewButtons({
    required this.isLast,
    required this.isSaving,
    required this.onRetake,
    required this.onAccept,
  });

  final bool isLast;
  final bool isSaving;
  final VoidCallback onRetake;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      spacing: context.saaf.space.x12,
      children: [
        Expanded(
          flex: 2,
          child: SaafButton.outline(
            label: l10n.scanRetake,
            onPressed: isSaving ? null : onRetake,
          ),
        ),
        Expanded(
          flex: 3,
          child: SaafButton.primary(
            label: isLast ? l10n.scanAnalyse : l10n.scanUsePhoto,
            isLoading: isSaving,
            onPressed: isSaving ? null : onAccept,
          ),
        ),
      ],
    );
  }
}
