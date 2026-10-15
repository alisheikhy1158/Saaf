/// Turns whatever the user typed or pasted into the "312 456 7890" shown in the
/// sign-up field: digits only, the country code and a leading 0 dropped, at most
/// ten digits, grouped 3-3-4. Pakistani mobile numbers start with 3, so a
/// leading "92" can only be the country code.
String formatPakistanMobileInput(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0092')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('92')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) digits = digits.substring(0, 10);

  final groups = <String>[];
  for (final (start, end) in const [(0, 3), (3, 6), (6, 10)]) {
    if (digits.length > start) {
      groups.add(digits.substring(start, digits.length.clamp(start, end)));
    }
  }
  return groups.join(' ');
}
