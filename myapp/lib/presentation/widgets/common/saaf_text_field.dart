import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/presentation/widgets/common/saaf_message_row.dart';

/// Labelled text field (design.md §6): label above, 56 dp tall, r14, optional
/// prefix + divider ("+92"), a sage check when [isValid], and a helper or
/// error row below. Borders and colours come from `ThemeData`.
class SaafTextField extends StatelessWidget {
  const SaafTextField({
    required this.label,
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText,
    this.prefixText,
    this.isValid = false,
    this.helperText,
    this.helperIcon,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  /// Shown before the input, followed by a thin divider (e.g. "+92").
  final String? prefixText;
  final bool isValid;
  final String? helperText;
  final IconData? helperIcon;

  /// When non-null the field is in its error state and this replaces the helper.
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final space = tokens.space;
    final size = tokens.size;
    final theme = Theme.of(context).inputDecorationTheme;
    final hasError = errorText != null;

    final prefix = prefixText == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(
              start: space.x16,
              end: space.x12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: space.x12,
              children: [
                Text(
                  prefixText!,
                  style: tokens.styles.inputText.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  key: const ValueKey('saaf-field-divider'),
                  width: size.phoneDividerWidth,
                  height: size.phoneDividerHeight,
                  child: ColoredBox(color: tokens.divider),
                ),
              ],
            ),
          );

    final suffix = isValid
        ? Padding(
            padding: EdgeInsetsDirectional.only(end: space.x16),
            child: Semantics(
              label: AppLocalizations.of(context).fieldValid,
              child: SizedBox.square(
                key: const ValueKey('saaf-field-valid'),
                dimension: size.checkSmall,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.sage,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: size.checkIconSmall,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: space.x8,
      children: [
        // The visible label is excluded from semantics; the field itself carries
        // it, so screen readers read "Mobile number, text field" once.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: space.x8,
          children: [
            ExcludeSemantics(
              child: Text(label, style: tokens.styles.fieldLabel),
            ),
            Semantics(
              label: label,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                enabled: enabled,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                inputFormatters: inputFormatters,
                style: tokens.styles.inputText,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefix,
                  prefixIconConstraints: const BoxConstraints(),
                  suffixIcon: suffix,
                  suffixIconConstraints: const BoxConstraints(),
                  contentPadding: prefix == null
                      ? null
                      : EdgeInsetsDirectional.only(
                          end: space.x16,
                          top: space.x16,
                          bottom: space.x16,
                        ),
                  enabledBorder: hasError ? theme.errorBorder : null,
                  focusedBorder: hasError ? theme.focusedErrorBorder : null,
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Semantics(
            liveRegion: true,
            child: SaafMessageRow(
              icon: Icons.error_outline,
              text: errorText!,
              color: context.colors.error,
            ),
          )
        else if (helperText != null)
          SaafMessageRow(
            icon: helperIcon,
            text: helperText!,
            color: tokens.textCaption,
          ),
      ],
    );
  }
}
