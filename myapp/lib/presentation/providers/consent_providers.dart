import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/core/config/policy_version.dart';
import 'package:saaf/data/repositories/in_memory_consent_repository.dart';
import 'package:saaf/data/services/system_clock.dart';
import 'package:saaf/domain/repositories/consent_repository.dart';
import 'package:saaf/domain/services/clock.dart';
import 'package:saaf/domain/usecases/accept_consent.dart';

part 'consent_providers.g.dart';

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

/// Swapped for the drift-backed repository in Phase 7.
@Riverpod(keepAlive: true)
ConsentRepository consentRepository(Ref ref) => InMemoryConsentRepository();

@riverpod
AcceptConsent acceptConsent(Ref ref) => AcceptConsent(
  repository: ref.watch(consentRepositoryProvider),
  clock: ref.watch(clockProvider),
  policyVersion: currentPolicyVersion,
);
