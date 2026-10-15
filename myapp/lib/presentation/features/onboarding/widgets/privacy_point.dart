import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_circle.dart';

/// One privacy promise on the consent screen: icon circle, bold title, caption.
class PrivacyPoint extends StatelessWidget {
  const PrivacyPoint({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.space.benefitGap,
        children: [
          SaafIconCircle(icon: icon, tone: SaafIconCircleTone.inkTint),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: tokens.space.x2,
              children: [
                Text(title, style: tokens.styles.listTitle),
                Text(body, style: tokens.styles.pointCaption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
