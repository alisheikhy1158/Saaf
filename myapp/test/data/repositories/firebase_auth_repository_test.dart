// Covers: docs/adr/0001-backend.md (Firebase Auth behind AuthRepository), PLAN 4.2
// (phone OTP, Google, Apple), SEC-7 (sign out), architecture §3.10 (failures,
// no throws). Firebase is mocked: nothing here touches the network.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saaf/core/error/failure.dart';
import 'package:saaf/data/repositories/firebase_auth_repository.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/entities/phone_number.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

class FakeAuthProvider extends Fake implements AuthProvider {}

void main() {
  late MockAuth auth;
  late FirebaseAuthRepository repository;
  final phone = PhoneNumber.parse('312 456 7890').valueOrNull!;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(FakeAuthProvider());
    registerFallbackValue(Duration.zero);
    // mocktail needs a stand-in for every non-nullable parameter type it matches.
    registerFallbackValue((PhoneAuthCredential credential) {});
    registerFallbackValue((FirebaseAuthException error) {});
    registerFallbackValue((String verificationId, int? resendToken) {});
    registerFallbackValue((String verificationId) {});
  });

  setUp(() {
    auth = MockAuth();
    repository = FirebaseAuthRepository(authProvider: () async => auth);
  });

  MockUserCredential signedIn({
    String uid = 'u1',
    String? phoneNumber,
    String? displayName,
  }) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.phoneNumber).thenReturn(phoneNumber);
    when(() => user.displayName).thenReturn(displayName);
    final credential = MockUserCredential();
    when(() => credential.user).thenReturn(user);
    return credential;
  }

  /// Stubs verifyPhoneNumber so it calls [onCall] with the named callbacks.
  void stubVerifyPhoneNumber(void Function(Invocation call) onCall) {
    when(
      () => auth.verifyPhoneNumber(
        phoneNumber: any(named: 'phoneNumber'),
        verificationCompleted: any(named: 'verificationCompleted'),
        verificationFailed: any(named: 'verificationFailed'),
        codeSent: any(named: 'codeSent'),
        codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        timeout: any(named: 'timeout'),
        forceResendingToken: any(named: 'forceResendingToken'),
      ),
    ).thenAnswer((call) async => onCall(call));
  }

  void sendsCode({String verificationId = 'vid-1', int? token = 7}) =>
      stubVerifyPhoneNumber((call) {
        final codeSent = call.namedArguments[#codeSent] as PhoneCodeSent;
        codeSent(verificationId, token);
      });

  group('requestOtp', () {
    test(
      'asks Firebase to text the E.164 number and reports the 30 s resend delay',
      () async {
        sendsCode();
        final result = await repository.requestOtp(phone);

        expect(result.valueOrNull?.resendAfter, const Duration(seconds: 30));
        final captured = verify(
          () => auth.verifyPhoneNumber(
            phoneNumber: captureAny(named: 'phoneNumber'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
            timeout: any(named: 'timeout'),
            forceResendingToken: any(named: 'forceResendingToken'),
          ),
        ).captured;
        expect(captured.single, '+923124567890');
      },
    );

    test('a network error becomes NetworkFailure', () async {
      stubVerifyPhoneNumber((call) {
        (call.namedArguments[#verificationFailed] as PhoneVerificationFailed)(
          FirebaseAuthException(code: 'network-request-failed'),
        );
      });
      expect(
        (await repository.requestOtp(phone)).failureOrNull,
        const NetworkFailure(),
      );
    });

    test(
      'Firebase rejecting the number becomes ValidationFailure("phone")',
      () async {
        stubVerifyPhoneNumber((call) {
          (call.namedArguments[#verificationFailed] as PhoneVerificationFailed)(
            FirebaseAuthException(code: 'invalid-phone-number'),
          );
        });
        expect(
          (await repository.requestOtp(phone)).failureOrNull,
          const ValidationFailure('phone'),
        );
      },
    );

    test('rate limiting is reported as a failure, never thrown', () async {
      stubVerifyPhoneNumber((call) {
        (call.namedArguments[#verificationFailed] as PhoneVerificationFailed)(
          FirebaseAuthException(code: 'too-many-requests'),
        );
      });
      expect(
        (await repository.requestOtp(phone)).failureOrNull,
        const UnknownFailure('too-many-requests'),
      );
    });

    test('an exception from Firebase is caught', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenThrow(StateError('not initialised'));
      expect((await repository.requestOtp(phone)).isOk, isFalse);
    });

    test('asking again reuses the resend token', () async {
      sendsCode(token: 7);
      await repository.requestOtp(phone);
      sendsCode(verificationId: 'vid-2', token: 8);
      await repository.requestOtp(phone);

      final tokens = verify(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: captureAny(named: 'forceResendingToken'),
        ),
      ).captured;
      expect(tokens, [null, 7]);
    });
  });

  group('verifyOtp', () {
    test('signs in with the verification id and the typed code', () async {
      sendsCode(verificationId: 'vid-1');
      await repository.requestOtp(phone);
      when(() => auth.signInWithCredential(any())).thenAnswer(
        (_) async => signedIn(uid: 'u1', phoneNumber: '+923124567890'),
      );

      final result = await repository.verifyOtp(phone: phone, code: '482913');

      expect(
        result.valueOrNull,
        const AuthSession(userId: 'u1', phoneE164: '+923124567890'),
      );
      final credential =
          verify(() => auth.signInWithCredential(captureAny())).captured.single
              as PhoneAuthCredential;
      expect(credential.verificationId, 'vid-1');
      expect(credential.smsCode, '482913');
    });

    test('a wrong code becomes ValidationFailure("code")', () async {
      sendsCode();
      await repository.requestOtp(phone);
      when(
        () => auth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'invalid-verification-code'));
      expect(
        (await repository.verifyOtp(
          phone: phone,
          code: '000000',
        )).failureOrNull,
        const ValidationFailure('code'),
      );
    });

    test(
      'an expired code is a failure the user can fix by resending',
      () async {
        sendsCode();
        await repository.requestOtp(phone);
        when(
          () => auth.signInWithCredential(any()),
        ).thenThrow(FirebaseAuthException(code: 'session-expired'));
        expect(
          (await repository.verifyOtp(
            phone: phone,
            code: '123456',
          )).failureOrNull,
          const UnknownFailure('session-expired'),
        );
      },
    );

    test('verifying before a code was requested fails cleanly', () async {
      final result = await repository.verifyOtp(phone: phone, code: '123456');
      expect(result.failureOrNull, const UnknownFailure('no-verification'));
      verifyNever(() => auth.signInWithCredential(any()));
    });

    test('a network error becomes NetworkFailure', () async {
      sendsCode();
      await repository.requestOtp(phone);
      when(
        () => auth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      expect(
        (await repository.verifyOtp(
          phone: phone,
          code: '123456',
        )).failureOrNull,
        const NetworkFailure(),
      );
    });
  });

  group(
    'automatic sign-in (Android instant verification / SMS auto-retrieval)',
    () {
      test(
        'verificationCompleted signs in and announces the session',
        () async {
          when(() => auth.signInWithCredential(any())).thenAnswer(
            (_) async => signedIn(uid: 'u9', phoneNumber: '+923124567890'),
          );
          stubVerifyPhoneNumber((call) {
            (call.namedArguments[#verificationCompleted]
                as PhoneVerificationCompleted)(
              PhoneAuthProvider.credential(
                verificationId: 'v',
                smsCode: '111111',
              ),
            );
          });

          final sessions = <AuthSession?>[];
          final sub = repository.sessionChanges.listen(sessions.add);
          await repository.requestOtp(phone);
          await Future<void>.delayed(Duration.zero);
          await sub.cancel();

          expect(sessions, [
            const AuthSession(userId: 'u9', phoneE164: '+923124567890'),
          ]);
        },
      );
    },
  );

  group('Google and Apple', () {
    test('Google signs in through the provider flow', () async {
      when(
        () => auth.signInWithProvider(any()),
      ).thenAnswer((_) async => signedIn(uid: 'g1'));
      final result = await repository.signInWithGoogle();
      expect(result.valueOrNull, const AuthSession(userId: 'g1'));
      expect(
        verify(() => auth.signInWithProvider(captureAny())).captured.single,
        isA<GoogleAuthProvider>(),
      );
    });

    test('the name from Google / Apple becomes the display name', () async {
      when(() => auth.signInWithProvider(any())).thenAnswer(
        (_) async => signedIn(uid: 'g2', displayName: '  Ayesha Khan '),
      );
      final result = await repository.signInWithGoogle();
      expect(
        result.valueOrNull,
        const AuthSession(userId: 'g2', displayName: 'Ayesha Khan'),
      );
    });

    test('a blank display name is treated as no name', () async {
      when(
        () => auth.signInWithProvider(any()),
      ).thenAnswer((_) async => signedIn(uid: 'g3', displayName: '   '));
      final result = await repository.signInWithGoogle();
      expect(result.valueOrNull?.displayName, isNull);
    });

    test('Apple signs in through the provider flow', () async {
      when(
        () => auth.signInWithProvider(any()),
      ).thenAnswer((_) async => signedIn(uid: 'a1'));
      final result = await repository.signInWithApple();
      expect(result.valueOrNull?.userId, 'a1');
      expect(
        verify(() => auth.signInWithProvider(captureAny())).captured.single,
        isA<AppleAuthProvider>(),
      );
    });

    test('cancelling is a quiet failure', () async {
      when(
        () => auth.signInWithProvider(any()),
      ).thenThrow(FirebaseAuthException(code: 'canceled'));
      expect(
        (await repository.signInWithGoogle()).failureOrNull,
        const UnknownFailure('canceled'),
      );
    });

    test('a network error becomes NetworkFailure', () async {
      when(
        () => auth.signInWithProvider(any()),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      expect(
        (await repository.signInWithApple()).failureOrNull,
        const NetworkFailure(),
      );
    });
  });

  group('session', () {
    test('currentSession maps the Firebase user', () async {
      final user = MockUser();
      when(() => user.uid).thenReturn('u1');
      when(() => user.phoneNumber).thenReturn('+923124567890');
      when(() => auth.currentUser).thenReturn(user);
      expect(
        await repository.currentSession(),
        const AuthSession(userId: 'u1', phoneE164: '+923124567890'),
      );
    });

    test('currentSession is null when nobody is signed in', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect(await repository.currentSession(), isNull);
    });

    test(
      'an empty phone number on the user means no phone (social sign-in)',
      () async {
        final user = MockUser();
        when(() => user.uid).thenReturn('g1');
        when(() => user.phoneNumber).thenReturn('');
        when(() => auth.currentUser).thenReturn(user);
        expect((await repository.currentSession())?.phoneE164, isNull);
      },
    );

    test('signOut signs out of Firebase and announces no session', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});
      final sessions = <AuthSession?>[];
      final sub = repository.sessionChanges.listen(sessions.add);
      await repository.signOut();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      verify(() => auth.signOut()).called(1);
      expect(sessions, [null]);
    });
  });

  group('deleteAccount', () {
    test('deletes the Firebase user and announces no session', () async {
      final user = MockUser();
      when(() => user.delete()).thenAnswer((_) async {});
      when(() => auth.currentUser).thenReturn(user);
      final sessions = <AuthSession?>[];
      final sub = repository.sessionChanges.listen(sessions.add);
      final result = await repository.deleteAccount();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(result.isOk, isTrue);
      verify(() => user.delete()).called(1);
      expect(sessions, [null]);
    });

    test('nobody signed in: nothing to delete, still fine', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect((await repository.deleteAccount()).isOk, isTrue);
    });

    test('an old login is asked to sign in again first', () async {
      final user = MockUser();
      when(
        () => user.delete(),
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));
      when(() => auth.currentUser).thenReturn(user);
      expect(
        (await repository.deleteAccount()).failureOrNull,
        const UnknownFailure('requires-recent-login'),
      );
    });

    test('a network error is a NetworkFailure', () async {
      final user = MockUser();
      when(
        () => user.delete(),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      when(() => auth.currentUser).thenReturn(user);
      expect(
        (await repository.deleteAccount()).failureOrNull,
        const NetworkFailure(),
      );
    });
  });

  group('mapFirebaseAuthError', () {
    const table = <String, Failure>{
      'network-request-failed': NetworkFailure(),
      'invalid-phone-number': ValidationFailure('phone'),
      'invalid-verification-code': ValidationFailure('code'),
      'too-many-requests': UnknownFailure('too-many-requests'),
      'quota-exceeded': UnknownFailure('quota-exceeded'),
      'session-expired': UnknownFailure('session-expired'),
      'canceled': UnknownFailure('canceled'),
      'something-new': UnknownFailure('something-new'),
    };
    table.forEach((code, expected) {
      test(code, () {
        expect(
          mapFirebaseAuthError(FirebaseAuthException(code: code)),
          expected,
        );
      });
    });
  });
}
