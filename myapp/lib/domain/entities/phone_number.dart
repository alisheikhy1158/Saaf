import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';

/// A Pakistani mobile number (+92 3XX XXXXXXX), validated and normalised.
/// Numbers written differently ("0312 4567890", "+92 312 456 7890") are equal.
final class PhoneNumber {
  const PhoneNumber._(this.nationalNumber);

  /// The country calling code shown before the number.
  static const String dialCode = '+92';

  /// The ten digits after the country code, e.g. "3124567890".
  final String nationalNumber;

  /// Parses what a user typed. Accepts spaces, dashes and brackets, a leading 0,
  /// or the country code as "+92", "0092" or "92".
  static Result<PhoneNumber> parse(String input) {
    const invalid = Err<PhoneNumber>(ValidationFailure('phone'));
    final text = input.trim();
    if (!RegExp(r'^\+?[\d\s\-()]+$').hasMatch(text)) return invalid;

    var digits = text.replaceAll(RegExp(r'\D'), '');
    if (text.startsWith('+')) {
      if (!digits.startsWith('92')) return invalid;
      digits = digits.substring(2);
    } else if (digits.startsWith('0092')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('92') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (!RegExp(r'^3\d{9}$').hasMatch(digits)) return invalid;
    return Ok(PhoneNumber._(digits));
  }

  /// International format for the backend: "+923124567890".
  String get e164 => '$dialCode$nationalNumber';

  /// How the app shows it: "+92 312 456 7890".
  String get display =>
      '$dialCode ${nationalNumber.substring(0, 3)} '
      '${nationalNumber.substring(3, 6)} ${nationalNumber.substring(6)}';

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && other.nationalNumber == nationalNumber;

  @override
  int get hashCode => nationalNumber.hashCode;

  @override
  String toString() => 'PhoneNumber(${nationalNumber.substring(0, 3)}…)';
}
