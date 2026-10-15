import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// On-screen number pad (Figma 03): 3 × 4 keys, 24/700 digits, a delete key.
/// Always laid out 1-2-3 left to right, also in right-to-left languages.
/// [enabled] false ignores taps (while a request is running).
class SaafKeypad extends StatelessWidget {
  const SaafKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.deleteLabel,
    super.key,
    this.enabled = true,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;

  /// Screen-reader label of the delete key.
  final String deleteLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final styles = tokens.styles;

    Widget key({
      required Object id,
      required Widget child,
      required String label,
      required VoidCallback onTap,
    }) => Expanded(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        onTap: enabled ? onTap : null,
        excludeSemantics: true,
        child: Material(
          key: ValueKey('saaf-key-$id'),
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: tokens.space.x14,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );

    Widget digit(int d) => key(
      id: d,
      label: '$d',
      onTap: () => onDigit(d),
      child: Text('$d', style: styles.keypadKey),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        spacing: tokens.space.x4,
        children: [
          for (final row in const [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Row(
              spacing: tokens.space.x4,
              children: [for (final d in row) digit(d)],
            ),
          Row(
            spacing: tokens.space.x4,
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: SizedBox(
                    key: const ValueKey('saaf-key-blank'),
                    height: styles.keypadKey.fontSize! + tokens.space.x14 * 2,
                  ),
                ),
              ),
              digit(0),
              key(
                id: 'delete',
                label: deleteLabel,
                onTap: onDelete,
                child: Icon(
                  Icons.backspace_outlined,
                  size: tokens.size.keypadIcon,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
