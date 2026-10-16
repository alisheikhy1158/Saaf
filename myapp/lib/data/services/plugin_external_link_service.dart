import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/external_link_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens links in the phone's browser through `url_launcher`.
class PluginExternalLinkService implements ExternalLinkService {
  /// [launch] is replaceable so tests need no phone.
  PluginExternalLinkService({Future<bool> Function(Uri uri)? launch})
    : _launch = launch ?? _browser;

  final Future<bool> Function(Uri uri) _launch;

  static Future<bool> _browser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<Result<void>> open(String url) async {
    final uri = Uri.tryParse(url.trim());
    final isWeb =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    if (!isWeb) return const Err(ValidationFailure('url'));

    try {
      final opened = await _launch(uri);
      return opened ? const Ok<void>(null) : const Err(UnknownFailure('link'));
    } on Object {
      return const Err(UnknownFailure('link'));
    }
  }
}
