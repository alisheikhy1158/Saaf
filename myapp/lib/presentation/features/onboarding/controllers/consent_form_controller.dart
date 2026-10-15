import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/presentation/features/onboarding/state/consent_form_state.dart';
import 'package:saaf/presentation/providers/consent_providers.dart';

part 'consent_form_controller.g.dart';

@riverpod
class ConsentFormController extends _$ConsentFormController {
  @override
  ConsentFormState build() => const ConsentFormState();

  void setTermsAccepted(bool value) =>
      state = state.copyWith(termsAccepted: value, failure: null);

  void setAgeConfirmed(bool value) =>
      state = state.copyWith(ageConfirmed: value, failure: null);

  /// Stores the consent. Returns true when it was saved.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    state = state.copyWith(isSubmitting: true, failure: null);
    final result = await ref.read(acceptConsentProvider)(
      termsAccepted: state.termsAccepted,
      ageConfirmed: state.ageConfirmed,
    );
    state = state.copyWith(isSubmitting: false, failure: result.failureOrNull);
    return result.isOk;
  }
}
