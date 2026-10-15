import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_check.dart';

/// Checkbox row (design.md §6): a 24 dp r7 box (sage + ink tick when checked,
/// faint 1.5 dp outline when not), 12 dp gap, 14/20/700 label.
///
/// The whole row toggles and is at least 48 dp tall (§9.1). It is announced as
/// one checkbox named [semanticLabel]; any links inside [label] should also be
/// offered as [customActions] so screen-reader users can reach them.
class SaafCheckRow extends StatelessWidget {
  const SaafCheckRow({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.semanticLabel,
    super.key,
    this.customActions = const {},
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final String semanticLabel;

  /// Extra screen-reader actions, by label (e.g. "Open Terms of Use").
  final Map<String, VoidCallback> customActions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;

    return Semantics(
      checked: value,
      label: semanticLabel,
      onTap: () => onChanged(!value),
      customSemanticsActions: {
        for (final action in customActions.entries)
          CustomSemanticsAction(label: action.key): action.value,
      },
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
          child: Row(
            spacing: tokens.space.x12,
            children: [
              SaafCheck(checked: value),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: tokens.styles.checkLabel,
                  child: label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
