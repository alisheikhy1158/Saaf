/// The phone's notification permission, as far as the app can tell.
enum NotificationPermission {
  granted,

  /// Not allowed yet, or refused once: the system dialog can still be shown.
  denied,

  /// Refused for good (or restricted): only the phone's settings can change it.
  permanentlyDenied,
}
