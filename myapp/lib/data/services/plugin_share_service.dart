import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/share_service.dart';
import 'package:share_plus/share_plus.dart';

/// The share sheet through `share_plus` (phones and Chrome).
class PluginShareService implements ShareService {
  /// [share] is replaceable so tests need no phone.
  PluginShareService({Future<void> Function(String text)? share})
    : _share = share ?? _systemShare;

  final Future<void> Function(String text) _share;

  static Future<void> _systemShare(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  @override
  Future<Result<void>> shareText(String text) async {
    if (text.trim().isEmpty) return const Err(ValidationFailure('text'));
    try {
      await _share(text);
      return const Ok<void>(null);
    } on Object {
      return const Err(UnknownFailure('share'));
    }
  }
}
