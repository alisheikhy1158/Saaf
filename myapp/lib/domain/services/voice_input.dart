/// Turning the user's voice into text with the phone's own speech service
/// (Google on Android, Apple on iOS). Only the resulting text is used by the
/// app; it is sent to the AI coach only when the user taps send.
abstract interface class VoiceInput {
  /// Starts listening in [languageCode] ("en" or "ur"); [onWords] gets the
  /// words so far, and `done` once the user stops speaking. False when speech
  /// is not available (no permission, no speech service).
  Future<bool> start({
    required String languageCode,
    required void Function(String words, bool done) onWords,
  });

  Future<void> stop();
}
