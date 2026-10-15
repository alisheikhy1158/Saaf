import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saaf/domain/entities/phone_number.dart';

part 'pending_sign_in.g.dart';

/// A code has been texted to [phone]; the user is entering it on Verify code.
/// A new instance is created on every request, so the countdown restarts.
class PendingSignIn {
  const PendingSignIn({required this.phone, required this.resendAfter});

  final PhoneNumber phone;
  final Duration resendAfter;
}

@Riverpod(keepAlive: true)
class PendingSignInNotifier extends _$PendingSignInNotifier {
  @override
  PendingSignIn? build() => null;

  void set(PendingSignIn? value) => state = value;
}
