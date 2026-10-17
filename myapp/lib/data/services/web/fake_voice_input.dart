import 'package:saaf/domain/services/voice_input.dart';

/// Pretends the user asked a question out loud (Chrome and demos).
class FakeVoiceInput implements VoiceInput {
  const FakeVoiceInput();

  @override
  Future<bool> start({
    required String languageCode,
    required void Function(String words, bool done) onWords,
  }) async {
    onWords(
      languageCode == 'ur'
          ? 'کیا میرا روٹین میری جلد کے لیے ٹھیک ہے؟'
          : 'Is my routine right for my skin?',
      true,
    );
    return true;
  }

  @override
  Future<void> stop() async {}
}
