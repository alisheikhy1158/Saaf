import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_theme.dart';

/// Shows [child] in the dark theme whatever the app theme is: ink background,
/// cornsilk text. Used by the camera screen (Figma 06 is always dark, the recipe
/// the whole dark theme is derived from, design.md §2.3). Follows the OS
/// high-contrast setting.
class SaafDarkScope extends StatelessWidget {
  const SaafDarkScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = Theme.of(context);
    if (current.brightness == Brightness.dark) return child;
    return Theme(
      data: MediaQuery.highContrastOf(context)
          ? SaafTheme.highContrastDark()
          : SaafTheme.dark(),
      child: child,
    );
  }
}
