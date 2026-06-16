import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _authTokenKey = 'auth_token';
  static const _selectedLanguageKey = 'selected_language';
  static const _selectedLocationKey = 'selected_location';

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String? getAuthToken() => _prefs.getString(_authTokenKey);

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_authTokenKey);
  }

  String? getSelectedLanguageCode() => _prefs.getString(_selectedLanguageKey);

  Future<void> saveSelectedLanguageCode(String languageCode) async {
    await _prefs.setString(_selectedLanguageKey, languageCode);
  }

  String? getSelectedLocationJson() => _prefs.getString(_selectedLocationKey);

  Future<void> saveSelectedLocationJson(String locationJson) async {
    await _prefs.setString(_selectedLocationKey, locationJson);
  }

  SharedPreferences get _prefs {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('LocalStorageService.init must be called before use.');
    }
    return preferences;
  }
}
