import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences 얇은 래퍼.
/// repository 구현체가 직접 SharedPreferences를 다루지 않게 한다.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String? readString(String key) => _prefs.getString(key);

  Future<bool> writeString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
