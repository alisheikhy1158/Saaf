/// What the user chose to tell Saaf about themself, kept only on the phone: a
/// name to show on Profile and an age (skin care advice depends on both a bit).
class ProfileDetails {
  const ProfileDetails({this.name, this.age});

  final String? name;
  final int? age;

  static const maxNameLength = 40;

  /// The app is for adults and older teens (store target audience 16+).
  static const minAge = 16;
  static const maxAge = 99;

  /// [raw] without extra spaces, or null when it is empty or too long.
  static String? cleanName(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty || name.length > maxNameLength) return null;
    return name;
  }

  /// The age in [raw], or null when it is not a number from [minAge] to [maxAge].
  static int? parseAge(String raw) {
    final age = int.tryParse(raw.trim());
    if (age == null || age < minAge || age > maxAge) return null;
    return age;
  }

  /// Reads an age that was stored as text; anything unreadable is "no age".
  static int? ageFromStored(String? text) =>
      text == null ? null : parseAge(text);
}
