import 'package:flutter/material.dart';
import 'package:saaf/presentation/widgets/common/saaf_icon_button.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Screen top bar (design.md §6): optional [leading] / [trailing] icon buttons
/// and a centred [title] (16/800). Empty slots keep the title centred.
///
/// Figma draws 40 dp buttons with 4 dp above and 12 dp below. The buttons here
/// have a 48 dp hit area (§9.1), so that extra 4 dp per side is taken out of the
/// padding: the circles sit exactly where Figma puts them and the bar is 56 dp.
class SaafTopBar extends StatelessWidget {
  const SaafTopBar({super.key, this.title, this.leading, this.trailing});

  /// A bar with only a back chevron on the leading side.
  SaafTopBar.back({
    required String tooltip,
    required VoidCallback onBack,
    super.key,
    this.title,
  }) : leading = backButton(tooltip: tooltip, onBack: onBack),
       trailing = null;

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  /// The Figma "icon-btn" with a left chevron (mirrors in RTL).
  static Widget backButton({
    required String tooltip,
    required VoidCallback onBack,
  }) => SaafIconButton(
    icon: Icons.chevron_left,
    tooltip: tooltip,
    onPressed: onBack,
  );

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final extra = (tokens.size.minTouchTarget - tokens.size.iconButton) / 2;
    final slot = SizedBox.square(dimension: tokens.size.minTouchTarget);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: tokens.space.topBarTop - extra,
        bottom: tokens.space.topBarBottom - extra,
      ),
      child: Row(
        children: [
          leading ?? slot,
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: context.text.labelLarge,
                  ),
          ),
          trailing ?? slot,
        ],
      ),
    );
  }
}
