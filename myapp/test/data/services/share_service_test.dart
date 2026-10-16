// Covers: 07 share button — text only, never photos (PRV-2); errors are Failures
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/services/plugin_share_service.dart';
import 'package:saaf/data/services/web/fake_share_service.dart';

void main() {
  group('FakeShareService', () {
    test('remembers what was shared', () async {
      final service = FakeShareService();
      expect((await service.shareText('hello')).isOk, isTrue);
      expect(service.shared, ['hello']);
    });
  });

  group('PluginShareService', () {
    test('hands the text to the share sheet', () async {
      String? seen;
      final service = PluginShareService(share: (text) async => seen = text);
      expect((await service.shareText('my score')).isOk, isTrue);
      expect(seen, 'my score');
    });

    test('empty text is rejected before anything opens', () async {
      var opened = false;
      final service = PluginShareService(share: (_) async => opened = true);
      final result = await service.shareText('  ');
      expect(result.failureOrNull, const ValidationFailure('text'));
      expect(opened, isFalse);
    });

    test('a sharing error becomes a failure, not an exception', () async {
      final service = PluginShareService(
        share: (_) async => throw StateError('x'),
      );
      expect((await service.shareText('hi')).failureOrNull, isA<Failure>());
    });
  });
}
