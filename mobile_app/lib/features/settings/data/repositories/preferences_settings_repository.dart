import '../../../../core/storage/preferences_store.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class PreferencesSettingsRepository implements SettingsRepository {
  const PreferencesSettingsRepository(this._store);

  final PreferencesStore _store;

  static const _themeModeKey = 'settings.themeMode';
  static const _languageCodeKey = 'settings.languageCode';
  static const _connectionModeKey = 'settings.connectionMode';

  @override
  AppSettings load() => AppSettings(
    themeMode: _store.readString(_themeModeKey) ?? 'system',
    languageCode: _store.readString(_languageCodeKey),
    connectionMode: _store.readString(_connectionModeKey) ?? 'mock',
  );

  @override
  Future<void> saveThemeMode(String value) =>
      _requireSuccess(_store.writeString(_themeModeKey, value));

  @override
  Future<void> saveLanguageCode(String? value) async {
    final success = value == null
        ? await _store.remove(_languageCodeKey)
        : await _store.writeString(_languageCodeKey, value);
    if (!success) throw StateError('Could not save the selected language.');
  }

  @override
  Future<void> saveConnectionMode(String value) =>
      _requireSuccess(_store.writeString(_connectionModeKey, value));

  Future<void> _requireSuccess(Future<bool> operation) async {
    if (!await operation) throw StateError('Could not save app settings.');
  }
}
