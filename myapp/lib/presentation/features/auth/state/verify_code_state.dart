import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/domain/usecases/verify_otp.dart';

part 'verify_code_state.freezed.dart';

@freezed
abstract class VerifyCodeState with _$VerifyCodeState {
  const factory VerifyCodeState({
    /// Digits entered so far (0–6).
    @Default('') String code,
    @Default(false) bool isSubmitting,
    Failure? failure,
  }) = _VerifyCodeState;

  const VerifyCodeState._();

  bool get isComplete => code.length == VerifyOtp.codeLength;
  bool get canSubmit => isComplete && !isSubmitting;
}
