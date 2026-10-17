/// A web search for where [product] is sold in Pakistan and for how much.
/// Saaf AI does not state prices (those it found were often out of date), so
/// the app sends the user to check them, in the phone's browser.
String priceSearchUrl(String product) => Uri.https(
  'www.google.com',
  '/search',
  {'q': '$product price in Pakistan'},
).toString();
