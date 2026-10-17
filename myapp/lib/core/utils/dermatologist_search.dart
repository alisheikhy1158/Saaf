/// A Google Maps search for dermatologists in [city] (or near the user),
/// opened in the phone's browser or Maps app.
String dermatologistSearchUrl(String? city) =>
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': city == null
          ? 'dermatologist near me'
          : 'dermatologist in $city',
    }).toString();
