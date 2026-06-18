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

  // Save user credentials (email and password)
  Future<void> saveUserCredentials(String email, String password) async {
    await sharedPreferences.setString('user_email', email);
    await sharedPreferences.setString('user_password', password);
  }

  // Get saved email
  String getUserEmail() {
    return sharedPreferences.getString('user_email') ?? '';
  }

  // Get saved password
  String getUserPassword() {
    return sharedPreferences.getString('user_password') ?? '';
  }

  // Clear user credentials
  Future<void> clearUserCredentials() async {
    await sharedPreferences.remove('user_email');
    await sharedPreferences.remove('user_password');
  }

  // Save user profile details
  Future<void> saveUserProfile(Map<String, dynamic> userData, {bool? is2faEnabled}) async {
    if (userData.containsKey('id') && userData['id'] != null) {
      await sharedPreferences.setString('logged_in_user_id', userData['id'].toString());
    }
    if (userData.containsKey('name') && userData['name'] != null) {
      await sharedPreferences.setString('user_name', userData['name'].toString());
    }
    if (userData.containsKey('email') && userData['email'] != null) {
      await sharedPreferences.setString('user_email', userData['email'].toString());
    }
    if (userData.containsKey('photo') && userData['photo'] != null) {
      await sharedPreferences.setString('user_photo', userData['photo'].toString());
    }
    if (userData.containsKey('cover') && userData['cover'] != null) {
      await sharedPreferences.setString('user_cover', userData['cover'].toString());
    }
    if (is2faEnabled != null) {
      await sharedPreferences.setBool('is_2fa_enabled', is2faEnabled);
    } else if (userData.containsKey('is_2fa_enabled')) {
      final val = userData['is_2fa_enabled'];
      await sharedPreferences.setBool('is_2fa_enabled', val == true || val.toString() == '1' || val.toString() == 'true');
    }

    if (userData['profile'] is Map) {
      final profile = userData['profile'] as Map<String, dynamic>;
      if (profile.containsKey('sms_notifications') && profile['sms_notifications'] != null) {
        final val = profile['sms_notifications'];
        await sharedPreferences.setBool('sms_notifications', val == true || val.toString() == '1' || val.toString() == 'true');
      }
      if (profile.containsKey('push_notifications') && profile['push_notifications'] != null) {
        final val = profile['push_notifications'];
        await sharedPreferences.setBool('push_notifications', val == true || val.toString() == '1' || val.toString() == 'true');
      }
      if (profile.containsKey('email_notifications') && profile['email_notifications'] != null) {
        final val = profile['email_notifications'];
        await sharedPreferences.setBool('email_notifications', val == true || val.toString() == '1' || val.toString() == 'true');
      }
      if (profile.containsKey('is_2fa_enabled') && profile['is_2fa_enabled'] != null) {
        final val = profile['is_2fa_enabled'];
        await sharedPreferences.setBool('is_2fa_enabled', val == true || val.toString() == '1' || val.toString() == 'true');
      }
    }
  }

  String getUserName() => sharedPreferences.getString('user_name') ?? '';
  String getUserPhoto() => sharedPreferences.getString('user_photo') ?? '';
  String getUserCover() => sharedPreferences.getString('user_cover') ?? '';
  bool getSmsNotifications() => sharedPreferences.getBool('sms_notifications') ?? false;
  bool getPushNotifications() => sharedPreferences.getBool('push_notifications') ?? true;
  bool getEmailNotifications() => sharedPreferences.getBool('email_notifications') ?? false;
  bool getIs2faEnabled() => sharedPreferences.getBool('is_2fa_enabled') ?? false;

  // Get last login time
  DateTime? getLastLoginTime() {
    final ms = sharedPreferences.getInt('last_login_timestamp');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  // Save last login time
  Future<void> saveLastLoginTime() async {
    await sharedPreferences.setInt('last_login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // Clear Preferences
  Future<bool> clear() async {
    return await sharedPreferences.clear();
  }
}
