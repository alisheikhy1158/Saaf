/// Small settings kept on the phone, by name: reminders, language, appearance.
abstract interface class SettingsRepository {
  Future<String?> read(String name);

  /// A null [value] forgets the setting.
  Future<void> write(String name, String? value);
}
