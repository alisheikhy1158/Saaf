// Covers: architecture.md OFF-1 (local source of truth; drift version replaces
// this in-memory one later), SEC-7 (clear on logout/delete)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/data/repositories/in_memory_consent_repository.dart';
import 'package:saaf/domain/entities/consent_record.dart';

void main() {
  final record = ConsentRecord(
    acceptedAt: DateTime.utc(2026, 10, 16),
    policyVersion: '2026-10',
  );

  test('starts empty', () async {
    expect(await InMemoryConsentRepository().current(), isNull);
  });

  test('returns what was saved', () async {
    final repository = InMemoryConsentRepository();
    await repository.save(record);
    expect(await repository.current(), record);
  });

  test('clear forgets the consent (logout / account deletion)', () async {
    final repository = InMemoryConsentRepository();
    await repository.save(record);
    await repository.clear();
    expect(await repository.current(), isNull);
  });

  test('ConsentRecord has value equality', () {
    expect(
      record,
      ConsentRecord(
        acceptedAt: DateTime.utc(2026, 10, 16),
        policyVersion: '2026-10',
      ),
    );
    expect(
      record,
      isNot(
        ConsentRecord(
          acceptedAt: DateTime.utc(2026, 10, 16),
          policyVersion: '2026-11',
        ),
      ),
    );
  });
}
