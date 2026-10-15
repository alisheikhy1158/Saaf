import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Fill of a [SaafChip] (design.md §6).
enum SaafChipTone { sage, papaya, ink, cornsilk, onDark, sageTint }

/// Display pill (r18). Pair meaning with an [icon] or text, never colour alone
/// (A11Y-7). [small] is the tighter 11/14 variant used for "Save 44%".
class SaafChip extends StatelessWidget {
  const SaafChip({
    required this.label,
    super.key,
    this.icon,
    this.tone = SaafChipTone.sage,
    this.small = false,
  });

  final String label;
  final IconData? icon;
  final SaafChipTone tone;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.saaf;
    final space = tokens.space;

    final (Color fill, Color foreground) = switch (tone) {
      SaafChipTone.sage => (colors.primary, colors.onPrimary),
      SaafChipTone.papaya => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      SaafChipTone.ink => (colors.inverseSurface, colors.onInverseSurface),
      SaafChipTone.cornsilk => (colors.surface, colors.onSurface),
      SaafChipTone.onDark => (tokens.controlOnInk, colors.onInverseSurface),
      SaafChipTone.sageTint => (tokens.sageTint, colors.onSurface),
    };

    final textStyle = (small ? tokens.styles.micro : context.text.labelMedium)
        ?.copyWith(color: foreground);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(tokens.radius.r18),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: small ? space.smallChipPaddingH : space.chipPaddingH,
            vertical: small ? space.smallChipPaddingV : space.chipPaddingV,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: space.chipIconGap,
            children: [
              if (icon != null)
                Icon(icon, size: tokens.size.iconChip, color: foreground),
              Flexible(child: Text(label, style: textStyle)),
            ],
          ),
        ),
      ),
    );
  }
}
