import 'package:saaf/domain/repositories/settings_repository.dart';

/// The user's explicit permission to send their chat messages and photos to the
/// AI service (Apple 5.1.2(i): say who receives them and ask first). Kept on the
/// phone and can be withdrawn at any time.
class AiConsent {
  AiConsent(this._settings, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Where the permission is stored (the date it was given).
  static const settingName = 'ai_consent';

  final SettingsRepository _settings;
  final DateTime Function() _now;

  Future<bool> isGiven() async => await _settings.read(settingName) != null;

  Future<void> give() => _settings.write(settingName, _now().toIso8601String());

  Future<void> withdraw() => _settings.write(settingName, null);
}
