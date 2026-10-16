import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// The dark card (07 score, 09 progress, 14 Pro promo): ink in the light theme,
/// lifted cornsilk-on-ink in the dark theme. r24, 20 dp padding. Text inside
/// should use `colors.onInverseSurface`.
class SaafInkCard extends StatelessWidget {
  const SaafInkCard({required this.child, super.key, this.padding});

  final Widget child;

  /// Defaults to the 20 dp ink-card padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.inverseSurface,
        borderRadius: BorderRadius.circular(tokens.radius.r24),
      ),
      child: Padding(
        padding:
            padding ?? EdgeInsetsDirectional.all(tokens.space.inkCardPadding),
        child: child,
      ),
    );
  }
}
