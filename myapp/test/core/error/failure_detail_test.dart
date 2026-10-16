// Covers: the technical detail line shown under sign-in errors in TEST builds
// (so a failure on a real phone can be diagnosed), never in store builds
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/failure_detail.dart';

void main() {
  test('an unknown failure shows its code', () {
    expect(
      failureDetail(const UnknownFailure('missing-client-identifier')),
      'missing-client-identifier',
    );
  });

  test('a network failure says network', () {
    expect(failureDetail(const NetworkFailure()), 'network');
  });

  test('a validation failure names the field', () {
    expect(failureDetail(const ValidationFailure('phone')), 'invalid phone');
  });

  test('no code is "unknown"', () {
    expect(failureDetail(const UnknownFailure()), 'unknown');
  });

  test('other failures show their kind', () {
    expect(failureDetail(const PermissionDenied()), 'PermissionDenied');
  });

  group('withDetail', () {
    test('is just the message when diagnostics are off', () {
      expect(
        withDetail(
          'We couldn’t send the code.',
          const NetworkFailure(),
          show: false,
        ),
        'We couldn’t send the code.',
      );
    });

    test('adds the technical line when they are on', () {
      expect(
        withDetail(
          'We couldn’t send the code.',
          const UnknownFailure('x'),
          show: true,
        ),
        'We couldn’t send the code.\n(Technical detail: x)',
      );
    });
  });
}
