import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/share_service.dart';

/// Remembers what would have been shared (tests and Chrome demos).
class FakeShareService implements ShareService {
  final List<String> shared = [];
  final List<SharedFile> files = [];

  @override
  Future<Result<void>> shareText(String text) async {
    shared.add(text);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> shareFile(SharedFile file, {String? text}) async {
    files.add(file);
    return const Ok<void>(null);
  }
}
