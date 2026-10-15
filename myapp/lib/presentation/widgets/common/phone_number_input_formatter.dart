import 'package:flutter/services.dart';
import 'package:saaf/core/utils/phone_format.dart';

/// Shows a Pakistani mobile number as "312 456 7890" while it is typed or pasted.
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = formatPakistanMobileInput(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
