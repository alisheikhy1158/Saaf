import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';

/// A signed-in user. [phoneE164] is null for Google / Apple sign-in.
/// Tokens are NOT held here: they live only in secure storage (SEC-1).
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({required String userId, String? phoneE164}) =
      _AuthSession;
}
