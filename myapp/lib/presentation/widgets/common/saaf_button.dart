import 'package:flutter/material.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

enum SaafButtonVariant { primary, outline, text }

/// Saaf button (design.md §6): primary (sage fill), outline (1.5 dp ink border)
/// or text. All colours, size and shape come from `ThemeData`.
///
/// While [isLoading] a spinner replaces the trailing icon and taps are ignored.
/// A null [onPressed] disables the button.
class SaafButton extends StatelessWidget {
  const SaafButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = SaafButtonVariant.primary;

  const SaafButton.outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
  }) : variant = SaafButtonVariant.outline;

  const SaafButton.text({
    required this.label,
    required this.onPressed,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
  }) : variant = SaafButtonVariant.text;

  final SaafButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;

  /// Usually `Icons.arrow_forward`; mirrored automatically in RTL.
  final IconData? trailingIcon;
  final bool isLoading;

  /// Fill the available width (Figma buttons span the content column).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final iconSize = tokens.size.icon;

    Widget icon(IconData data) => Icon(data, size: iconSize);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: tokens.space.x8,
      children: [
        if (leadingIcon != null) icon(leadingIcon!),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (isLoading)
          Builder(
            builder: (context) => SizedBox.square(
              dimension: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: tokens.size.borderFocus,
                color: IconTheme.of(context).color,
              ),
            ),
          )
        else if (trailingIcon != null)
          icon(trailingIcon!),
      ],
    );

    // While loading the button keeps its normal look but ignores taps.
    final VoidCallback? effectiveOnPressed = isLoading ? () {} : onPressed;

    final button = switch (variant) {
      SaafButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
      SaafButtonVariant.outline => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
      SaafButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
