import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/policy_version.dart';
import 'package:saaf/data/local/drift_repositories.dart';
import 'package:saaf/data/repositories/in_memory_consent_repository.dart';
import 'package:saaf/data/services/system_clock.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/usecases/accept_consent.dart';
import 'package:saaf/presentation/providers/database_providers.dart';

part 'consent_providers.g.dart';

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

/// Drift on the phone; in memory in tests and Chrome.
@Riverpod(keepAlive: true)
ConsentRepository consentRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db == null ? InMemoryConsentRepository() : DriftConsentRepository(db);
}

@riverpod
AcceptConsent acceptConsent(Ref ref) => AcceptConsent(
  repository: ref.watch(consentRepositoryProvider),
  clock: ref.watch(clockProvider),
  policyVersion: currentPolicyVersion,
);
