import 'package:saaf/core/error/failure.dart';
import 'package:saaf/core/error/result.dart';
import 'package:saaf/domain/entities/auth_session.dart';
import 'package:saaf/domain/repositories/auth_repository.dart';

enum SocialProvider { google, apple }

/// Sign in with Google or Apple.
class SocialSignIn {
  const SocialSignIn(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call(SocialProvider provider) async {
    try {
      return switch (provider) {
        SocialProvider.google => await _repository.signInWithGoogle(),
        SocialProvider.apple => await _repository.signInWithApple(),
      };
    } on Object {
      return const Err(UnknownFailure('socialSignIn'));
    }
  }
}
