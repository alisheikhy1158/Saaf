import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Cornsilk card with the Figma hairline border and r20 corners; the shape and
/// colours come from `ThemeData.cardTheme`. Pass [onTap] (and a
/// [semanticLabel]) to make the whole card a button.
class SaafCard extends StatelessWidget {
  const SaafCard({
    required this.child,
    super.key,
    this.padding,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;

  /// Defaults to the 20 dp ink-card padding.
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final inner = Padding(
      padding:
          padding ??
          EdgeInsetsDirectional.all(context.saaf.space.inkCardPadding),
      child: child,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? inner
          : Semantics(
              button: true,
              label: semanticLabel,
              child: InkWell(onTap: onTap, child: inner),
            ),
    );
  }
}
