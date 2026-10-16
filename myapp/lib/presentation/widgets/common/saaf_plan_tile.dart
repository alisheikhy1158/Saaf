import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';
import 'package:saaf/presentation/widgets/common/saaf_chip.dart';

/// A subscription plan to pick (Figma 13 "Plan"): a round tick, the plan name
/// with an optional [badge] ("Save 44%"), a caption and the price. Selected =
/// 2 dp ink border. The whole tile is one tap target, announced as a checkbox
/// named [semanticLabel].
class SaafPlanTile extends StatelessWidget {
  const SaafPlanTile({
    required this.title,
    required this.caption,
    required this.price,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
    super.key,
    this.badge,
  });

  final String title;
  final String caption;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final String semanticLabel;

  /// Small chip next to the title, e.g. "Save 44%".
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final radius = BorderRadius.circular(tokens.radius.r20);

    return Semantics(
      checked: selected,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        key: const ValueKey('saaf-plan-box'),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? context.colors.onSurface : tokens.borderControl,
            width: selected
                ? tokens.size.borderSelectedPlan
                : tokens.size.borderThin,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: tokens.size.minTouchTarget,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.space.planPaddingH,
                  vertical: tokens.space.planPaddingV,
                ),
                child: Row(
                  spacing: tokens.space.benefitGap,
                  children: [
                    SaafCheck(checked: selected, shape: SaafCheckShape.circle),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: tokens.space.x4,
                        children: [
                          Wrap(
                            spacing: tokens.space.x8,
                            runSpacing: tokens.space.x4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(title, style: context.text.labelLarge),
                              if (badge != null)
                                SaafChip(
                                  label: badge!,
                                  small: true,
                                  tone: SaafChipTone.sageTint,
                                ),
                            ],
                          ),
                          Text(caption, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    // Shrinks a little at very large text sizes instead of overflowing.
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(price, style: context.text.titleSmall),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
