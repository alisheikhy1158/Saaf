import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_product_thumbnail.dart';

/// One product line (Figma 08 / 09 "Routine step"): thumbnail, name, a caption
/// and a [trailing] widget (a price on 08, a tick on 09), with a hairline under
/// it unless [isLast].
///
/// Pass [onTap] (and [semanticLabel] / [checked]) to make the whole row one
/// tappable checkbox, as on Home; without them it is read as plain text.
class SaafRoutineStepRow extends StatelessWidget {
  const SaafRoutineStepRow({
    required this.name,
    required this.caption,
    required this.trailing,
    required this.isLast,
    super.key,
    this.onTap,
    this.checked,
    this.semanticLabel,
  });

  final String name;
  final String caption;
  final Widget trailing;
  final bool isLast;
  final VoidCallback? onTap;

  /// Set together with [onTap] when the row is a checkbox.
  final bool? checked;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: tokens.rowDivider,
                  width: tokens.size.borderThin,
                ),
              ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            vertical: tokens.space.rowPaddingV,
          ),
          child: Row(
            spacing: tokens.space.rowGap,
            children: [
              const SaafProductThumbnail(),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: tokens.space.x2,
                  children: [
                    Text(
                      name,
                      // Product names are English catalogue data.
                      textDirection: TextDirection.ltr,
                      style: tokens.styles.listTitle,
                    ),
                    Text(caption, style: context.text.bodySmall),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return MergeSemantics(child: content);

    return Semantics(
      checked: checked,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
