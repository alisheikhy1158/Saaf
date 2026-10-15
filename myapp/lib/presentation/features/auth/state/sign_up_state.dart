import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/entities/phone_number.dart';

part 'sign_up_state.freezed.dart';

@freezed
abstract class SignUpState with _$SignUpState {
  const factory SignUpState({
    /// What is in the phone field, as typed ("312 456 7890").
    @Default('') String input,
    @Default(false) bool isSubmitting,

    /// The code could not be sent.
    Failure? sendFailure,

    /// Google / Apple sign-in failed.
    Failure? socialFailure,
  }) = _SignUpState;

  const SignUpState._();

  bool get isValid => PhoneNumber.parse(input).isOk;
  bool get canSend => isValid && !isSubmitting;
}
