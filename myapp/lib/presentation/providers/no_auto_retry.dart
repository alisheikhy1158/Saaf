/// Riverpod 3 retries a failed provider on its own. Screens that show an error
/// with a "Try again" button turn that off with `@Riverpod(retry: noAutoRetry)`,
/// so the failure shows at once instead of being retried behind the user's back.
Duration? noAutoRetry(int retryCount, Object error) => null;
