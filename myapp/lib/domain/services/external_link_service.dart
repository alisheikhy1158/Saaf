import 'package:saaf/core/error/result.dart';

/// Opens a web page in the phone's own browser (store links, Buy buttons).
/// Only http(s) addresses are accepted (SEC-8).
abstract interface class ExternalLinkService {
  Future<Result<void>> open(String url);
}
