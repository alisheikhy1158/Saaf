/// A city the user can choose for the daily skin weather (no location
/// permission needed). Places are the city centres, rounded.
class PkCity {
  const PkCity(this.id, this.lat, this.lon);

  /// Also the key of its name in the app's translations.
  final String id;
  final double lat;
  final double lon;

  static const all = [
    PkCity('karachi', 24.86, 67.01),
    PkCity('lahore', 31.55, 74.34),
    PkCity('islamabad', 33.69, 73.05),
    PkCity('rawalpindi', 33.60, 73.04),
    PkCity('faisalabad', 31.42, 73.08),
    PkCity('multan', 30.20, 71.47),
    PkCity('peshawar', 34.01, 71.58),
    PkCity('quetta', 30.18, 66.98),
    PkCity('hyderabad', 25.40, 68.37),
    PkCity('gujranwala', 32.16, 74.19),
    PkCity('sialkot', 32.49, 74.52),
    PkCity('bahawalpur', 29.40, 71.68),
    PkCity('sukkur', 27.70, 68.86),
    PkCity('abbottabad', 34.15, 73.21),
  ];

  static PkCity? byId(String? id) {
    for (final city in all) {
      if (city.id == id) return city;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is PkCity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
