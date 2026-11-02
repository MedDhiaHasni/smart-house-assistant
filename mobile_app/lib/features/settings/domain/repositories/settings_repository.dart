import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> saveThemeMode(String value);

  Future<void> saveLanguageCode(String? value);

  Future<void> saveConnectionMode(String value);
}
