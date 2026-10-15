import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';

/// Result of asking for a code: the validated number plus the backend's
/// challenge, which is everything the verify screen needs.
final class SentOtp {
  const SentOtp({required this.phone, required this.challenge});

  final PhoneNumber phone;
  final OtpChallenge challenge;
}
