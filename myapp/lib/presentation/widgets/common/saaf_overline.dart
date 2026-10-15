import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Small spaced-out caps label ("STEP 2 OF 5", "ROUTINE"): 12/800 with 8 %
/// letter-spacing. Faint (ink @ 45 %) unless [strong] (full ink, as on 05).
class SaafOverline extends StatelessWidget {
  const SaafOverline(this.text, {super.key, this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: strong
          ? context.text.labelSmall?.copyWith(color: context.colors.onSurface)
          : context.text.labelSmall,
    );
  }
}
