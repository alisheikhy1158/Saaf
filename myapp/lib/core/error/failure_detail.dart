import 'package:saaf/core/error/failure.dart';

/// A short technical description of [failure], for diagnosing problems on a real
/// phone. Never contains personal data (SEC-6).
String failureDetail(Failure failure) => switch (failure) {
  UnknownFailure(:final message) => message ?? 'unknown',
  NetworkFailure() => 'network',
  ServiceUnavailable(:final reason?) => reason,
  ValidationFailure(:final field) => 'invalid $field',
  _ => failure.runtimeType.toString(),
};

/// [message] with the technical line under it when [show] is on (test builds
/// only: `--dart-define=DIAGNOSTICS=true`).
String withDetail(String message, Failure failure, {required bool show}) =>
    show ? '$message\n(Technical detail: ${failureDetail(failure)})' : message;
