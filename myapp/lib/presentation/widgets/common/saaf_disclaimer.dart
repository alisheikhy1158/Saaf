import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Info icon plus a small caption (07 "A cosmetic screening, not a medical
/// diagnosis…"). Not decoration: the text is read by screen readers.
class SaafDisclaimer extends StatelessWidget {
  const SaafDisclaimer(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space.x8,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.info_outline,
            size: tokens.size.iconSmall,
            color: tokens.textCaption,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: tokens.styles.legal.copyWith(color: tokens.textCaption),
          ),
        ),
      ],
    );
  }
}
