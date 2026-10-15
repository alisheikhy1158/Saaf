import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

enum SaafCheckShape { rounded, circle }

/// 22 / 24 / 26 dp (Figma 02 / 05+13 / 09).
enum SaafCheckSize { small, medium, large }

/// The tick box (design.md §6): checked = sage fill + ink tick, unchecked = a
/// 1.5 dp outline at 25 % ink. Purely visual — the control that owns it
/// announces the state (A11Y-7: the tick, not just the colour, shows it).
class SaafCheck extends StatelessWidget {
  const SaafCheck({
    required this.checked,
    super.key,
    this.shape = SaafCheckShape.rounded,
    this.size = SaafCheckSize.medium,
  });

  final bool checked;
  final SaafCheckShape shape;
  final SaafCheckSize size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final (dimension, tickSize) = switch (size) {
      SaafCheckSize.small => (
        tokens.size.checkSmall,
        tokens.size.checkIconSmall,
      ),
      SaafCheckSize.medium => (
        tokens.size.checkMedium,
        tokens.size.checkIconMedium,
      ),
      SaafCheckSize.large => (tokens.size.check, tokens.size.checkIcon),
    };
    final radius = switch (shape) {
      SaafCheckShape.circle => dimension / 2,
      SaafCheckShape.rounded => tokens.radius.r7,
    };

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: dimension,
        child: DecoratedBox(
          key: const ValueKey('saaf-check-box'),
          decoration: BoxDecoration(
            color: checked ? colors.primary : null,
            borderRadius: BorderRadius.circular(radius),
            border: checked
                ? null
                : Border.all(
                    color: tokens.checkBorder,
                    width: tokens.size.borderFocus,
                  ),
          ),
          child: checked
              ? Center(
                  child: Icon(
                    Icons.check,
                    size: tickSize,
                    color: colors.onPrimary,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
