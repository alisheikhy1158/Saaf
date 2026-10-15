// Covers: PLAN 4.5 (a fixed OTP for App Review / dev), SEC-7 (sign out clears
// the session). This fake is the dev/test backend until the real one (ADR 0001).
import 'package:flutter_test/flutter_test.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/repositories/fake_auth_repository.dart';
import 'package:saaf/domain/entities/phone_number.dart';

void main() {
  final phone = PhoneNumber.parse('312 456 7890').valueOrNull!;

  test('requesting a code succeeds with a 30 second resend delay', () async {
    final result = await FakeAuthRepository().requestOtp(phone);
    expect(result.valueOrNull?.resendAfter, const Duration(seconds: 30));
  });

  test('the fixed code signs the user in', () async {
    final repository = FakeAuthRepository();
    final result = await repository.verifyOtp(
      phone: phone,
      code: FakeAuthRepository.fixedCode,
    );
    expect(result.valueOrNull?.phoneE164, '+923124567890');
    expect(await repository.currentSession(), result.valueOrNull);
  });

  test('any other code is rejected and no session is created', () async {
    final repository = FakeAuthRepository();
    final result = await repository.verifyOtp(phone: phone, code: '000000');
    expect(result.failureOrNull, const ValidationFailure('code'));
    expect(await repository.currentSession(), isNull);
  });

  test('Google and Apple sign-in create a session', () async {
    expect((await FakeAuthRepository().signInWithGoogle()).isOk, isTrue);
    expect((await FakeAuthRepository().signInWithApple()).isOk, isTrue);
  });

  test('signing out forgets the session', () async {
    final repository = FakeAuthRepository();
    await repository.verifyOtp(
      phone: phone,
      code: FakeAuthRepository.fixedCode,
    );
    await repository.signOut();
    expect(await repository.currentSession(), isNull);
  });
}
