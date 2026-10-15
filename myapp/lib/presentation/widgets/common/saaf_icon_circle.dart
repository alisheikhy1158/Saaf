import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Circle diameters used in the Figma screens (design.md §4).
enum SaafIconCircleSize { small, welcome, regular, large }

/// Fills used in Figma (design.md §6 "icon-circle").
enum SaafIconCircleTone { sage, sageTint, tan, lightSage }

/// Decorative filled circle with a centred icon at half its size. Hidden from
/// screen readers (A11Y-2): the text next to it carries the meaning.
class SaafIconCircle extends StatelessWidget {
  const SaafIconCircle({
    required this.icon,
    super.key,
    this.size = SaafIconCircleSize.regular,
    this.tone = SaafIconCircleTone.sage,
    this.mirrorInRtl = false,
  });

  /// Set for direction-bearing icons (arrows); charts and logos stay as drawn.
  final bool mirrorInRtl;

  final IconData icon;
  final SaafIconCircleSize size;
  final SaafIconCircleTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final diameter = switch (size) {
      SaafIconCircleSize.small => tokens.size.iconCircleSmall,
      SaafIconCircleSize.welcome => tokens.size.iconCircleWelcome,
      SaafIconCircleSize.regular => tokens.size.iconCircle,
      SaafIconCircleSize.large => tokens.size.iconCircleLarge,
    };
    final fill = switch (tone) {
      SaafIconCircleTone.sage => tokens.sage,
      SaafIconCircleTone.sageTint => tokens.sageTint,
      SaafIconCircleTone.tan => tokens.tan,
      SaafIconCircleTone.lightSage => tokens.lightSage,
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
              color: colors.onPrimary,
              textDirection: mirrorInRtl ? null : TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }
}
