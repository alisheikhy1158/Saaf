import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/core/theme/tokens.dart';

/// Placeholder picture of a product (Figma 08 "Product image"): a small bottle
/// on a faint papaya square, 48 dp, r12. Decorative: the product name next to it
/// carries the meaning, so screen readers skip it (A11Y-2).
class SaafProductThumbnail extends StatelessWidget {
  const SaafProductThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: tokens.size.thumbnail,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.papayaTint,
            borderRadius: BorderRadius.circular(tokens.radius.r12),
          ),
          child: CustomPaint(
            painter: _BottlePainter(
              geometry: tokens.thumbnail,
              body: tokens.sage.withValues(alpha: SaafAlpha.thumbnailBody),
              cap: colors.onSurface.withValues(
                alpha: SaafAlpha.thumbnailDetail,
              ),
              label: colors.surface.withValues(
                alpha: SaafAlpha.thumbnailDetail,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  const _BottlePainter({
    required this.geometry,
    required this.body,
    required this.cap,
    required this.label,
  });

  final SaafThumbnailGeometry geometry;
  final Color body;
  final Color cap;
  final Color label;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / geometry.designSize;
    void draw(Rect rect, double radius, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left * scale,
            rect.top * scale,
            rect.width * scale,
            rect.height * scale,
          ),
          Radius.circular(radius * scale),
        ),
        Paint()..color = color,
      );
    }

    draw(geometry.body, geometry.bodyRadius, body);
    draw(geometry.cap, geometry.capRadius, cap);
    draw(geometry.label, geometry.labelRadius, label);
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.body != body || old.cap != cap || old.label != label;
}
