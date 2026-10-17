import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/services/share_service.dart';

/// Remembers what would have been shared (tests and Chrome demos).
class FakeShareService implements ShareService {
  final List<String> shared = [];
  final List<SharedImage> images = [];

  @override
  Future<Result<void>> shareText(String text) async {
    shared.add(text);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> shareImage(SharedImage image, {String? text}) async {
    images.add(image);
    return const Ok<void>(null);
  }
}
