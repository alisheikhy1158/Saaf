import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_challenge.freezed.dart';

/// The backend accepted a request to text a code. [resendAfter] is how long the
/// user must wait before asking for another.
@freezed
abstract class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({required Duration resendAfter}) = _OtpChallenge;
}
