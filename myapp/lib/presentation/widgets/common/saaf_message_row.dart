import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Small icon + caption row under a field: a helper (faint) or an error. Never
/// relies on colour alone: pass an icon (A11Y-7).
class SaafMessageRow extends StatelessWidget {
  const SaafMessageRow({
    required this.text,
    required this.color,
    super.key,
    this.icon,
  });

  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space.x6,
      children: [
        if (icon != null)
          Padding(
            padding: EdgeInsetsDirectional.only(top: tokens.space.x2),
            child: Icon(icon, size: tokens.size.iconChip, color: color),
          ),
        Expanded(
          child: Text(
            text,
            style: context.text.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
