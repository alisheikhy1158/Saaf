// Covers: 02 Sign up (the field formats "312 456 7890" while typing/pasting)
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/presentation/widgets/common/phone_number_input_formatter.dart';

TextEditingValue typed(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  final formatter = PhoneNumberInputFormatter();

  test('groups digits 3-3-4 as they are typed', () {
    var value = const TextEditingValue();
    for (final next in [
      '3',
      '31',
      '312',
      '3124',
      '31245',
      '312456',
      '3124567',
    ]) {
      value = formatter.formatEditUpdate(value, typed(next));
    }
    expect(value.text, '312 456 7');
  });

  test('keeps the cursor at the end', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      typed('3124567890'),
    );
    expect(result.text, '312 456 7890');
    expect(result.selection.baseOffset, result.text.length);
  });

  test('handles a pasted international number', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      typed('+92 312 4567890'),
    );
    expect(result.text, '312 456 7890');
  });

  test('drops letters and symbols', () {
    final result = formatter.formatEditUpdate(
      const TextEditingValue(),
      typed('3x1#2'),
    );
    expect(result.text, '312');
  });

  test('deleting a space-separated digit works', () {
    final result = formatter.formatEditUpdate(typed('312 4'), typed('312 '));
    expect(result.text, '312');
  });
}
