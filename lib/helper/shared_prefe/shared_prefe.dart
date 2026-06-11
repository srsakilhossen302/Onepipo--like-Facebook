import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  final SharedPreferences sharedPreferences;

  SharedPreferenceHelper({required this.sharedPreferences});

  // Save Data
  Future<bool> setString(String key, String value) async {
    return await sharedPreferences.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    return await sharedPreferences.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await sharedPreferences.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await sharedPreferences.setDouble(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await sharedPreferences.setStringList(key, value);
  }

  // Get Data
  String getString(String key, {String defaultValue = ''}) {
    return sharedPreferences.getString(key) ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return sharedPreferences.getBool(key) ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return sharedPreferences.getInt(key) ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return sharedPreferences.getDouble(key) ?? defaultValue;
  }

  List<String> getStringList(String key) {
    return sharedPreferences.getStringList(key) ?? [];
  }

  // Check if Key exists
  bool hasKey(String key) {
    return sharedPreferences.containsKey(key);
  }

  // Remove Key
  Future<bool> removeKey(String key) async {
    return await sharedPreferences.remove(key);
  }

  // Clear Preferences
  Future<bool> clear() async {
    return await sharedPreferences.clear();
  }
}
