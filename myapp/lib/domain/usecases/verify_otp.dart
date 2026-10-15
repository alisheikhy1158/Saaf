import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

/// Checks the code is six digits, then asks the backend to verify it.
class VerifyOtp {
  const VerifyOtp(this._repository);

  /// Length of the code we text.
  static const int codeLength = 6;

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required PhoneNumber phone,
    required String code,
  }) async {
    if (!RegExp('^\\d{$codeLength}\$').hasMatch(code)) {
      return const Err(ValidationFailure('code'));
    }
    try {
      return await _repository.verifyOtp(phone: phone, code: code);
    } on Object {
      return const Err(UnknownFailure('verifyOtp'));
    }
  }
}
