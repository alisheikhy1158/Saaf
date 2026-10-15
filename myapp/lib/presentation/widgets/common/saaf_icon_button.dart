import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Round icon button (design.md §6): 40 dp visual, 48 dp hit area (§9.1).
/// [tooltip] is required — it is also the screen-reader label (A11Y-1).
/// [onDark] is the translucent-cornsilk variant used on ink surfaces (06).
class SaafIconButton extends StatelessWidget {
  const SaafIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.onDark = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: onDark
          ? IconButton.styleFrom(
              backgroundColor: tokens.controlOnInk,
              foregroundColor: context.colors.onInverseSurface,
              side: BorderSide.none,
            )
          : null,
    );
  }
}
