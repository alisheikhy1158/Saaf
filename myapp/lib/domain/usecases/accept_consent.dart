import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/consent_record.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';
import 'package:saaf/domain/services/clock.dart';

/// Records the user's consent. Both the terms and the 16+ confirmation must be
/// given explicitly (never pre-ticked); nothing is stored otherwise.
class AcceptConsent {
  const AcceptConsent({
    required ConsentRepository repository,
    required Clock clock,
    required String policyVersion,
  }) : _repository = repository,
       _clock = clock,
       _policyVersion = policyVersion;

  final ConsentRepository _repository;
  final Clock _clock;
  final String _policyVersion;

  Future<Result<ConsentRecord>> call({
    required bool termsAccepted,
    required bool ageConfirmed,
  }) async {
    if (!termsAccepted) return const Err(ValidationFailure('terms'));
    if (!ageConfirmed) return const Err(ValidationFailure('age'));

    final record = ConsentRecord(
      acceptedAt: _clock.now(),
      policyVersion: _policyVersion,
    );
    try {
      await _repository.save(record);
    } on Object {
      return const Err(StorageFailure());
    }
    return Ok(record);
  }
}
