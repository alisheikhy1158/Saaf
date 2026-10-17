/// Everything that can go wrong, as plain values (architecture.md §3.10).
/// UI maps these to friendly, localised text — never show `toString()`.
sealed class Failure {
  const Failure();

  /// The fields that make two failures equal.
  List<Object?> get props => const [];

  @override
  bool operator ==(Object other) {
    if (other is! Failure || other.runtimeType != runtimeType) return false;
    final a = props;
    final b = other.props;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(props));

  @override
  String toString() => '$runtimeType${props.isEmpty ? '' : props}';
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// The AI coach was asked something without the user's explicit permission to
/// share their messages (store-compliance §5).
final class ConsentMissing extends Failure {
  const ConsentMissing();
}

/// Too many requests (the AI coach's daily limit).
final class RateLimited extends Failure {
  const RateLimited();
}

/// The service is down or not set up on this build. [reason] is the server's
/// short error code when it gave one (for the test app's detail line).
final class ServiceUnavailable extends Failure {
  const ServiceUnavailable([this.reason]);

  final String? reason;

  @override
  List<Object?> get props => [reason];
}

/// The user is not signed in (or the sign-in has expired).
final class Unauthorised extends Failure {
  const Unauthorised();
}

final class PermissionDenied extends Failure {
  const PermissionDenied();
}

final class StorageFailure extends Failure {
  const StorageFailure();
}

final class PurchaseCancelled extends Failure {
  const PurchaseCancelled();
}

/// An input did not pass validation at the boundary (SEC-8). [field] names it.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

final class UnknownFailure extends Failure {
  const UnknownFailure([this.message]);

  /// For logs only (never contains PII, SEC-6).
  final String? message;

  @override
  List<Object?> get props => [message];
}
