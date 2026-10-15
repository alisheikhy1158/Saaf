import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/core/error/failure.dart';

part 'consent_form_state.freezed.dart';

/// What the user has ticked on the Privacy consent screen. Nothing is ticked
/// by default: consent has to be an explicit action.
@freezed
abstract class ConsentFormState with _$ConsentFormState {
  const factory ConsentFormState({
    @Default(false) bool termsAccepted,
    @Default(false) bool ageConfirmed,
    @Default(false) bool isSubmitting,
    Failure? failure,
  }) = _ConsentFormState;

  const ConsentFormState._();

  bool get canSubmit => termsAccepted && ageConfirmed && !isSubmitting;
}
