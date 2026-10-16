import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// The rounded card around a list of [SaafSettingsRow]s (Figma 14 "Settings"):
/// cornsilk, r20, hairline border, 16 dp side padding, a faint line between rows.
class SaafSettingsGroup extends StatelessWidget {
  const SaafSettingsGroup({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radius.r20),
        border: Border.all(
          color: tokens.borderCard,
          width: tokens.size.borderThin,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.space.groupPaddingH,
          vertical: tokens.space.settingsGroupPaddingV,
        ),
        child: Column(
          children: [
            for (final (i, row) in rows.indexed)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: i == rows.length - 1
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: tokens.rowDivider,
                            width: tokens.size.borderThin,
                          ),
                        ),
                ),
                child: row,
              ),
          ],
        ),
      ),
    );
  }
}

/// One setting (Figma 14 "Row"): a 20 dp icon, the title, an optional value in
/// faint text and a chevron that points to the end of the line. The whole row is
/// the tap target and is announced as "title, value".
class SaafSettingsRow extends StatelessWidget {
  const SaafSettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.value,
    this.semanticLabel,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  /// Read instead of "title, value" when the default is not clear enough.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final label = semanticLabel ?? (value == null ? title : '$title, $value');

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: tokens.space.settingsRowPaddingV,
            ),
            child: Row(
              spacing: tokens.space.rowGap,
              children: [
                Icon(icon, size: tokens.size.icon),
                Expanded(child: Text(title, style: tokens.styles.rowTitle)),
                if (value != null)
                  Flexible(
                    child: Text(
                      value!,
                      textAlign: TextAlign.end,
                      style: tokens.styles.meta.copyWith(
                        color: tokens.textMeta,
                      ),
                    ),
                  ),
                Icon(
                  Icons.chevron_right,
                  size: tokens.size.iconSmall,
                  color: tokens.textMeta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
