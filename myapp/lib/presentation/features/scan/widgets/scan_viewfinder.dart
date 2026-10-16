import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/theme/tokens.dart';
import 'package:saaf/presentation/features/scan/state/scan_state.dart';
import 'package:saaf/presentation/features/scan/widgets/pose_text.dart';
import 'package:saaf/presentation/providers/scan_providers.dart';

/// The rounded camera area (Figma 06 "Viewfinder", r28): the live picture with
/// the dashed face oval and progress arc, a photo that was just taken, or a
/// [panel] (permission, error) when there is no camera.
class ScanViewfinder extends ConsumerWidget {
  const ScanViewfinder({required this.state, required this.panel, super.key});

  final ScanState state;

  /// Shown instead of the camera when the camera is not available.
  final Widget? panel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.saaf;
    final l10n = AppLocalizations.of(context);

    final Widget content;
    if (panel != null) {
      content = panel!;
    } else if (state.reviewPhoto != null) {
      final photo = state.reviewPhoto!;
      content = Semantics(
        image: true,
        label: l10n.scanPhotoOf(photo.pose.label(l10n)),
        child: Image.memory(
          photo.bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      );
    } else if (state.phase == ScanPhase.live) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label: l10n.scanCameraPreview,
            child: ref.watch(cameraPreviewSourceProvider).buildPreview(context),
          ),
          ExcludeSemantics(
            child: CustomPaint(
              painter: _GuidePainter(
                geometry: tokens.scan,
                guideColor: context.colors.onSurface,
                arcColor: tokens.sage,
                progress: _progress(state),
              ),
            ),
          ),
        ],
      );
    } else {
      content = const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius.r28),
      child: ColoredBox(color: tokens.trackSegmented, child: content),
    );
  }

  /// How much of the arc is drawn: one third per check that passes.
  static double _progress(ScanState state) {
    final q = state.quality;
    final passed = [q.lightOk, q.centred, q.steady].where((ok) => ok).length;
    return passed / 3;
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.geometry,
    required this.guideColor,
    required this.arcColor,
    required this.progress,
  });

  final SaafScanGeometry geometry;
  final Color guideColor;
  final Color arcColor;
  final double progress;

  Rect _scaled(Rect rect, Size size) {
    final sx = size.width / geometry.designWidth;
    final sy = size.height / geometry.designHeight;
    return Rect.fromLTRB(
      rect.left * sx,
      rect.top * sy,
      rect.right * sx,
      rect.bottom * sy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Path()..addOval(_scaled(geometry.guide, size));
    final dashed = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.guideStroke;
    for (final PathMetric metric in guide.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + geometry.dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), dashed);
        distance += geometry.dashLength + geometry.dashGap;
      }
    }

    if (progress > 0) {
      canvas.drawArc(
        _scaled(geometry.arc, size),
        geometry.arcStartAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = arcColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = geometry.arcStroke,
      );
    }
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.progress != progress ||
      old.guideColor != guideColor ||
      old.arcColor != arcColor;
}
