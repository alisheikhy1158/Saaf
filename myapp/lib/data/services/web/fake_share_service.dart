import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/share_service.dart';

/// Remembers what would have been shared (tests and Chrome demos).
class FakeShareService implements ShareService {
  final List<String> shared = [];

  @override
  Future<Result<void>> shareText(String text) async {
    shared.add(text);
    return const Ok<void>(null);
  }
}
