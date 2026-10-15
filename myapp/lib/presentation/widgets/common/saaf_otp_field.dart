import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';

/// Verification-code boxes (Figma 03): [length] boxes showing [value], the next
/// empty one active with a sage caret.
///
/// A transparent text field sits over the boxes, so tapping them opens the
/// system number keyboard, SMS autofill (`oneTimeCode`) and paste work, and
/// screen readers get one labelled text field instead of six boxes. The parent
/// may also drive [value] from an on-screen keypad.
class SaafOtpField extends StatefulWidget {
  const SaafOtpField({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
    this.length = 6,
    this.hasError = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String semanticLabel;
  final int length;
  final bool hasError;

  @override
  State<SaafOtpField> createState() => _SaafOtpFieldState();
}

class _SaafOtpFieldState extends State<SaafOtpField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(SaafOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final colors = context.colors;
    final active = widget.value.length < widget.length
        ? widget.value.length
        : -1;

    Widget box(int i) {
      final isActive = i == active;
      final digit = i < widget.value.length ? widget.value[i] : null;
      final borderColor = widget.hasError
          ? colors.error
          : isActive
          ? tokens.borderFocus
          : tokens.borderStrong;
      return Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.size.otpBoxWidth),
          child: SizedBox(
            height: tokens.size.otpBoxHeight,
            child: DecoratedBox(
              key: ValueKey('saaf-otp-box-$i'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.radius.r14),
                border: Border.all(
                  color: borderColor,
                  width: isActive || widget.hasError
                      ? tokens.size.borderFocus
                      : tokens.size.borderThin,
                ),
              ),
              child: Center(
                child: digit != null
                    ? Text(digit, style: tokens.styles.otpDigit)
                    : isActive
                    ? SizedBox(
                        width: tokens.size.caretWidth,
                        height: tokens.size.caretHeight,
                        child: DecoratedBox(
                          key: const ValueKey('saaf-otp-caret'),
                          decoration: BoxDecoration(color: tokens.sage),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (var i = 0; i < widget.length; i++) box(i)],
            ),
          ),
          // Invisible but NOT Opacity(0): a fully transparent Opacity drops its
          // subtree from the semantics tree, and screen readers need this field.
          Positioned.fill(
            child: Semantics(
              label: widget.semanticLabel,
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                enableInteractiveSelection: false,
                showCursor: false,
                style: const TextStyle(color: Colors.transparent),
                cursorColor: Colors.transparent,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
