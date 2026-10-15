import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Hairline divider with a short word in the middle ("or"). Decorative.
class SaafLabeledDivider extends StatelessWidget {
  const SaafLabeledDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;

    Widget line(Key key) => Expanded(
      child: SizedBox(
        height: tokens.size.borderThin,
        child: ColoredBox(key: key, color: tokens.borderOption),
      ),
    );

    return ExcludeSemantics(
      child: Row(
        spacing: tokens.space.x12,
        children: [
          line(const ValueKey('saaf-divider-start')),
          Text(label, style: tokens.styles.meta),
          line(const ValueKey('saaf-divider-end')),
        ],
      ),
    );
  }
}
