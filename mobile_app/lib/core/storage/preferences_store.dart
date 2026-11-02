import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStore {
  const PreferencesStore(this._preferences);

  final SharedPreferences _preferences;

  String? readString(String key) => _preferences.getString(key);

  Future<bool> writeString(String key, String value) =>
      _preferences.setString(key, value);

  Future<bool> remove(String key) => _preferences.remove(key);
}
