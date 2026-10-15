import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/entities/sent_otp.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

/// Validates the typed number, then asks the backend to text a code.
class RequestOtp {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<SentOtp>> call(String rawPhone) async {
    final parsed = PhoneNumber.parse(rawPhone);
    final phone = parsed.valueOrNull;
    if (phone == null) return Err(parsed.failureOrNull!);

    try {
      final result = await _repository.requestOtp(phone);
      return result.map(
        (challenge) => SentOtp(phone: phone, challenge: challenge),
      );
    } on Object {
      return const Err(UnknownFailure('requestOtp'));
    }
  }
}
