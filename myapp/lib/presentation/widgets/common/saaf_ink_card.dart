import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// The dark card (07 score, 09 progress, 14 Pro promo): ink in the light theme,
/// lifted cornsilk-on-ink in the dark theme. r24, 20 dp padding. Text inside
/// should use `colors.onInverseSurface`.
class SaafInkCard extends StatelessWidget {
  const SaafInkCard({
    required this.child,
    super.key,
    this.padding,
    this.compact = false,
    this.radius,
  });

  final Widget child;

  /// Defaults to the 20 dp ink-card padding.
  final EdgeInsetsGeometry? padding;

  /// The slightly tighter card of 12 Coach summary: r22 instead of r24.
  final bool compact;

  /// An exact corner radius (the 14 Pro promo is r20); wins over [compact].
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.inverseSurface,
        borderRadius: BorderRadius.circular(
          radius ?? (compact ? tokens.radius.r22 : tokens.radius.r24),
        ),
      ),
      child: Padding(
        padding:
            padding ?? EdgeInsetsDirectional.all(tokens.space.inkCardPadding),
        child: child,
      ),
    );
  }
}
