import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Circle diameters used in the Figma screens (design.md §4).
enum SaafIconCircleSize { compact, small, welcome, regular, large }

/// Fills used in Figma (design.md §6 "icon-circle").
enum SaafIconCircleTone { sage, sageTint, inkTint, tan, lightSage }

/// Icon colours used inside circles: the ink default, or sage (04's big shield).
enum SaafIconCircleColor { ink, sage }

/// Decorative filled circle with a centred icon at half its size. Hidden from
/// screen readers (A11Y-2): the text next to it carries the meaning.
class SaafIconCircle extends StatelessWidget {
  const SaafIconCircle({
    required this.icon,
    super.key,
    this.size = SaafIconCircleSize.regular,
    this.tone = SaafIconCircleTone.sage,
    this.iconColor = SaafIconCircleColor.ink,
    this.mirrorInRtl = false,
  });

  final IconData icon;
  final SaafIconCircleSize size;
  final SaafIconCircleTone tone;
  final SaafIconCircleColor iconColor;

  /// Set for direction-bearing icons (arrows); charts and logos stay as drawn.
  final bool mirrorInRtl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final diameter = switch (size) {
      SaafIconCircleSize.compact => tokens.size.iconCircleCompact,
      SaafIconCircleSize.small => tokens.size.iconCircleSmall,
      SaafIconCircleSize.welcome => tokens.size.iconCircleWelcome,
      SaafIconCircleSize.regular => tokens.size.iconCircle,
      SaafIconCircleSize.large => tokens.size.iconCircleLarge,
    };
    final fill = switch (tone) {
      SaafIconCircleTone.sage => tokens.sage,
      SaafIconCircleTone.sageTint => tokens.sageTint,
      SaafIconCircleTone.inkTint => tokens.inkTint,
      SaafIconCircleTone.tan => tokens.tan,
      SaafIconCircleTone.lightSage => tokens.lightSage,
    };
    final foreground = switch (iconColor) {
      SaafIconCircleColor.ink => colors.onPrimary,
      SaafIconCircleColor.sage => tokens.sage,
    };

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
          child: Center(
            child: Icon(
              icon,
              size: diameter / 2,
              color: foreground,
              textDirection: mirrorInRtl ? null : TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}
