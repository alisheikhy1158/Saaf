// Covers: PLAN 4.2 (phone OTP sign-in), SEC-8 (validate phone and 6-digit code
// before calling the backend), architecture §3.10 (Result, no throws)
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/otp_challenge.dart';
import 'package:saaf/domain/entities/phone_number.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';
import 'package:saaf/domain/usecases/request_otp.dart';
import 'package:saaf/domain/usecases/verify_otp.dart';

class RecordingAuthRepository implements AuthRepository {
  final requested = <PhoneNumber>[];
  final verified = <(PhoneNumber, String)>[];
  Result<OtpChallenge> requestResult = const Ok(
    OtpChallenge(resendAfter: Duration(seconds: 30)),
  );
  Result<AuthSession> verifyResult = const Ok(
    AuthSession(userId: 'u1', phoneE164: '+923124567890'),
  );

  @override
  Future<Result<OtpChallenge>> requestOtp(PhoneNumber phone) async {
    requested.add(phone);
    return requestResult;
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  }) async {
    verified.add((phone, code));
    return verifyResult;
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle() async => verifyResult;

  @override
  Future<Result<AuthSession>> signInWithApple() async => verifyResult;

  @override
  Future<AuthSession?> currentSession() async => null;

  @override
  Stream<AuthSession?> get sessionChanges => const Stream.empty();

  @override
  Future<void> signOut() async {}
}

void main() {
  late RecordingAuthRepository repository;

  setUp(() => repository = RecordingAuthRepository());

  group('RequestOtp', () {
    test('parses the number and asks the backend for a code', () async {
      final result = await RequestOtp(repository)('0312 4567890');
      expect(result.isOk, isTrue);
      expect(repository.requested.single.e164, '+923124567890');
      expect(result.valueOrNull?.phone.e164, '+923124567890');
      expect(
        result.valueOrNull?.challenge.resendAfter,
        const Duration(seconds: 30),
      );
    });

    test('rejects an invalid number without calling the backend', () async {
      final result = await RequestOtp(repository)('12345');
      expect(result.failureOrNull, const ValidationFailure('phone'));
      expect(repository.requested, isEmpty);
    });

    test('passes a backend failure through', () async {
      repository.requestResult = const Err(NetworkFailure());
      final result = await RequestOtp(repository)('312 456 7890');
      expect(result.failureOrNull, const NetworkFailure());
    });
  });

  group('VerifyOtp', () {
    final phone = PhoneNumber.parse('312 456 7890').valueOrNull!;

    test('sends the number and code and returns the session', () async {
      final result = await VerifyOtp(repository)(phone: phone, code: '482913');
      expect(result.valueOrNull?.userId, 'u1');
      expect(repository.verified.single.$2, '482913');
    });

    const badCodes = [
      '',
      '1234',
      '12345',
      '1234567',
      '12345a',
      '12 345',
      'abcdef',
    ];
    for (final code in badCodes) {
      test('rejects "$code" without calling the backend', () async {
        final result = await VerifyOtp(repository)(phone: phone, code: code);
        expect(result.failureOrNull, const ValidationFailure('code'));
        expect(repository.verified, isEmpty);
      });
    }

    test('a wrong code from the backend comes back as a failure', () async {
      repository.verifyResult = const Err(ValidationFailure('code'));
      final result = await VerifyOtp(repository)(phone: phone, code: '000000');
      expect(result.failureOrNull, const ValidationFailure('code'));
    });
  });
}
