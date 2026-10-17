import 'package:saaf/domain/services/voice_input.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech to text through the `speech_to_text` plugin. Bluetooth headsets are
/// left out on purpose (so no Bluetooth permission is needed). The plugin asks
/// for the microphone (and, on iOS, speech recognition) the first time.
class PluginVoiceInput implements VoiceInput {
  PluginVoiceInput();

  final SpeechToText _speech = SpeechToText();
  bool? _ready;

  static const _listenFor = Duration(seconds: 30);
  static const _pauseFor = Duration(seconds: 3);

  @override
  Future<bool> start({
    required String languageCode,
    required void Function(String words, bool done) onWords,
  }) async {
    try {
      _ready ??= await _speech.initialize(
        options: [SpeechToText.androidNoBluetooth],
      );
      if (_ready != true) return false;
      final wanted = languageCode == 'ur' ? 'ur_PK' : 'en_US';
      final locales = await _speech.locales();
      final localeId = locales.any((l) => l.localeId == wanted) ? wanted : null;
      await _speech.listen(
        onResult: (result) =>
            onWords(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenFor: _listenFor,
          pauseFor: _pauseFor,
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } on Object {
      // Already stopped.
    }
  }
}
