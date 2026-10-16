import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

part 'onboarding_status.g.dart';

/// Whether the user has consented: null while it is being read from storage,
/// then true or false. The router guard keeps the app closed until it is true.
@Riverpod(keepAlive: true)
class ConsentStatus extends _$ConsentStatus {
  @override
  bool? build() {
    ref.watch(consentRepositoryProvider).current().then((record) {
      if (ref.mounted && state == null) state = record != null;
    });
    return null;
  }

  void markGiven() => state = true;
}

/// Whether the skin quiz was finished (or skipped to the end). The router guard
/// sends a new user to the quiz until it is.
@Riverpod(keepAlive: true)
class QuizDone extends _$QuizDone {
  @override
  bool build() => false;

  void markDone() => state = true;
}
