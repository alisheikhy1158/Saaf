/// The phone screen as a light for the face scan: full brightness while the
/// selfie camera is open, the normal brightness again afterwards. Only the
/// app's own brightness changes, never the phone's setting.
abstract interface class ScreenLight {
  Future<void> brighten();
  Future<void> restore();
}
