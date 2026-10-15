import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

/// Selectable card with an icon, title, caption and a trailing tick (Figma 05
/// "Option"). The whole tile is the hit area and it is announced as one
/// checkbox named "title. caption".
class SaafOptionTile extends StatelessWidget {
  const SaafOptionTile({
    required this.icon,
    required this.title,
    required this.caption,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final radius = BorderRadius.circular(tokens.radius.r18);

    return Semantics(
      checked: selected,
      label: '$title. $caption',
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        key: const ValueKey('saaf-option-box'),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: radius,
          border: selected
              ? Border.all(
                  color: context.colors.onSurface,
                  width: tokens.size.borderFocus,
                )
              : Border.all(
                  color: tokens.borderOption,
                  width: tokens.size.borderThin,
                ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsetsDirectional.all(tokens.space.optionPadding),
              child: Row(
                spacing: tokens.space.benefitGap,
                children: [
                  SaafIconCircle(
                    icon: icon,
                    tone: selected
                        ? SaafIconCircleTone.sage
                        : SaafIconCircleTone.sageTint,
                    iconColor: selected
                        ? SaafIconCircleColor.ink
                        : SaafIconCircleColor.sage,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: tokens.space.x2,
                      children: [
                        Text(title, style: tokens.styles.listTitle),
                        Text(caption, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  SaafCheck(checked: selected, shape: SaafCheckShape.circle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
