import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/external_link_service.dart';

/// Remembers which links would have been opened (tests and Chrome demos).
class FakeExternalLinkService implements ExternalLinkService {
  final List<String> opened = [];

  @override
  Future<Result<void>> open(String url) async {
    opened.add(url);
    return const Ok<void>(null);
  }
}
