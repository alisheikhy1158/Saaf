// Covers: architecture.md §3.10 (repositories/use cases return Result<T> with a
// sealed Failure)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok carries a value', () {
      const Result<int> result = Ok(3);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 3);
      expect(result.failureOrNull, isNull);
    });

    test('Err carries a failure', () {
      const Result<int> result = Err(NetworkFailure());
      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, const NetworkFailure());
    });

    test('when() picks the matching branch', () {
      const Result<int> ok = Ok(2);
      const Result<int> err = Err(UnknownFailure('boom'));
      expect(ok.when(ok: (v) => 'ok $v', err: (f) => 'err'), 'ok 2');
      expect(err.when(ok: (v) => 'ok', err: (f) => 'err $f'), contains('err'));
    });

    test('map transforms only successes', () {
      expect(const Ok<int>(2).map((v) => v * 2).valueOrNull, 4);
      const Result<int> err = Err(StorageFailure());
      expect(err.map((v) => v * 2).failureOrNull, const StorageFailure());
    });
  });

  group('Failure', () {
    test('is a sealed family with the architecture §3.10 members', () {
      final failures = <Failure>[
        const NetworkFailure(),
        const PermissionDenied(),
        const StorageFailure(),
        const PurchaseCancelled(),
        const UnknownFailure('x'),
        const ValidationFailure('terms'),
      ];
      // An exhaustive switch compiles only if the hierarchy is sealed.
      for (final failure in failures) {
        final label = switch (failure) {
          NetworkFailure() => 'network',
          PermissionDenied() => 'permission',
          StorageFailure() => 'storage',
          PurchaseCancelled() => 'purchase',
          UnknownFailure() => 'unknown',
          ValidationFailure() => 'validation',
        };
        expect(label, isNotEmpty);
      }
    });

    test('value equality', () {
      expect(const ValidationFailure('a'), const ValidationFailure('a'));
      expect(const ValidationFailure('a'), isNot(const ValidationFailure('b')));
    });
  });
}
