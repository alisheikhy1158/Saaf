// Covers: PLAN Phase 5 (consent stored with timestamp + policy version),
// store-compliance §2 (16+ confirmation), §1 (privacy promises are contractual),
// SEC-8 (validate at the boundary)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/consent_record.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/usecases/accept_consent.dart';

class FakeClock implements Clock {
  FakeClock(this.value);
  DateTime value;
  @override
  DateTime now() => value;
}

class FakeConsentRepository implements ConsentRepository {
  ConsentRecord? saved;
  int saveCalls = 0;
  Object? throwOnSave;

  @override
  Future<ConsentRecord?> current() async => saved;

  @override
  Future<void> save(ConsentRecord record) async {
    saveCalls++;
    if (throwOnSave != null) throw throwOnSave!;
    saved = record;
  }

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  final now = DateTime.utc(2026, 10, 16, 9, 41);
  late FakeConsentRepository repository;
  late AcceptConsent acceptConsent;

  setUp(() {
    repository = FakeConsentRepository();
    acceptConsent = AcceptConsent(
      repository: repository,
      clock: FakeClock(now),
      policyVersion: '2026-10',
    );
  });

  test(
    'stores the consent with the clock time and the policy version',
    () async {
      final result = await acceptConsent(
        termsAccepted: true,
        ageConfirmed: true,
      );

      expect(result.isOk, isTrue);
      final record = result.valueOrNull!;
      expect(record.acceptedAt, now);
      expect(record.policyVersion, '2026-10');
      expect(repository.saved, record);
      expect(await repository.current(), record);
    },
  );

  test('rejects when the terms are not accepted, without saving', () async {
    final result = await acceptConsent(
      termsAccepted: false,
      ageConfirmed: true,
    );

    expect(result.failureOrNull, const ValidationFailure('terms'));
    expect(repository.saveCalls, 0);
  });

  test(
    'rejects when the 16+ confirmation is missing, without saving',
    () async {
      final result = await acceptConsent(
        termsAccepted: true,
        ageConfirmed: false,
      );

      expect(result.failureOrNull, const ValidationFailure('age'));
      expect(repository.saveCalls, 0);
    },
  );

  test('both missing reports the terms first', () async {
    final result = await acceptConsent(
      termsAccepted: false,
      ageConfirmed: false,
    );
    expect(result.failureOrNull, const ValidationFailure('terms'));
  });

  test('a storage error becomes StorageFailure, not an exception', () async {
    repository.throwOnSave = StateError('disk full');

    final result = await acceptConsent(termsAccepted: true, ageConfirmed: true);

    expect(result.failureOrNull, const StorageFailure());
  });

  test('accepting again replaces the previous record', () async {
    await acceptConsent(termsAccepted: true, ageConfirmed: true);
    final later = AcceptConsent(
      repository: repository,
      clock: FakeClock(now.add(const Duration(days: 1))),
      policyVersion: '2026-11',
    );
    await later(termsAccepted: true, ageConfirmed: true);

    expect(repository.saved?.policyVersion, '2026-11');
  });
}
