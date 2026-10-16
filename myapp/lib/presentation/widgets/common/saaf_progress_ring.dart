import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// A ring that fills clockwise from the top (07 score ring, 09 progress ring):
/// a faint track and a sage arc, with [child] in the middle. [value] is 0–1.
/// [semanticLabel] says what it shows ("Skin score 76 out of 100"); the child
/// is hidden from screen readers so the value is not read twice.
class SaafProgressRing extends StatelessWidget {
  const SaafProgressRing({
    required this.value,
    required this.size,
    required this.stroke,
    required this.semanticLabel,
    super.key,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final String semanticLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value.clamp(0.0, 1.0),
            stroke: stroke,
            track: tokens.trackOnInk,
            fill: tokens.sage,
            // Fills from the reading-direction start: mirrored in RTL.
            clockwise: Directionality.of(context) == TextDirection.ltr,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.fill,
    required this.clockwise,
  });

  final double value;
  final double stroke;
  final Color track;
  final Color fill;
  final bool clockwise;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, 2 * math.pi, false, paint..color = track);
    if (value <= 0) return;
    final sweep = 2 * math.pi * value * (clockwise ? 1 : -1);
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, paint..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.stroke != stroke ||
      old.track != track ||
      old.fill != fill ||
      old.clockwise != clockwise;
}
