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
