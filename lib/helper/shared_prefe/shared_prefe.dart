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
    if (userData.containsKey('username') && userData['username'] != null) {
      await sharedPreferences.setString('user_username', userData['username'].toString());
    } else if (userData['profile'] is Map) {
      final profile = userData['profile'] as Map<String, dynamic>;
      if (profile.containsKey('username') && profile['username'] != null) {
        await sharedPreferences.setString('user_username', profile['username'].toString());
      }
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
      if (profile.containsKey('bio') && profile['bio'] != null) {
        await sharedPreferences.setString('user_bio', profile['bio'].toString());
      }
      if (profile.containsKey('country_id') && profile['country_id'] != null) {
        await sharedPreferences.setString('user_country_id', profile['country_id'].toString());
      }
      if (profile.containsKey('city_id') && profile['city_id'] != null) {
        await sharedPreferences.setString('user_city_id', profile['city_id'].toString());
      }
      if (profile.containsKey('country') && profile['country'] != null) {
        await sharedPreferences.setString('user_country_name', profile['country'].toString());
      }
      if (profile.containsKey('followers_count') && profile['followers_count'] != null) {
        await sharedPreferences.setInt('followers_count', int.tryParse(profile['followers_count'].toString()) ?? 0);
      }
      if (profile.containsKey('following_count') && profile['following_count'] != null) {
        await sharedPreferences.setInt('following_count', int.tryParse(profile['following_count'].toString()) ?? 0);
      }
    }
  }

  String getUserId() => sharedPreferences.getString('logged_in_user_id') ?? '';
  String getUserName() => sharedPreferences.getString('user_name') ?? '';
  String getUserUsername() => sharedPreferences.getString('user_username') ?? '';
  String getUserPhoto() => sharedPreferences.getString('user_photo') ?? '';
  String getUserCover() => sharedPreferences.getString('user_cover') ?? '';
  String getUserBio() => sharedPreferences.getString('user_bio') ?? '';
  String getUserCountryId() => sharedPreferences.getString('user_country_id') ?? '';
  String getUserCityId() => sharedPreferences.getString('user_city_id') ?? '';
  String getUserCountryName() => sharedPreferences.getString('user_country_name') ?? '';
  String getUserCityName() => sharedPreferences.getString('user_city_name') ?? '';
  bool getSmsNotifications() => sharedPreferences.getBool('sms_notifications') ?? false;
  bool getPushNotifications() => sharedPreferences.getBool('push_notifications') ?? true;
  bool getEmailNotifications() => sharedPreferences.getBool('email_notifications') ?? false;
  bool getIs2faEnabled() => sharedPreferences.getBool('is_2fa_enabled') ?? false;
  int getFollowersCount() => sharedPreferences.getInt('followers_count') ?? 0;
  int getFollowingCount() => sharedPreferences.getInt('following_count') ?? 0;

  bool isMe({
    String? userId,
    String? userName,
    Map<String, dynamic>? authorRaw,
  }) {
    final loggedInUserId = sharedPreferences.getString('logged_in_user_id') ?? '';
    final loggedInUserName = getUserName();
    final loggedInUserUsername = getUserUsername();
    final loggedInUserEmail = getUserEmail();

    // 1. Check explicit ID
    if (loggedInUserId.isNotEmpty && userId != null && userId.isNotEmpty && loggedInUserId == userId) {
      return true;
    }

    // 2. Check Name/Username fallback
    if (loggedInUserName.isNotEmpty && userName != null && userName.isNotEmpty && userName.toLowerCase() == loggedInUserName.toLowerCase()) {
      return true;
    }
    if (loggedInUserUsername.isNotEmpty && userName != null && userName.isNotEmpty && userName.toLowerCase() == loggedInUserUsername.toLowerCase()) {
      return true;
    }

    // 3. Check authorRaw map (id, name, username, email)
    if (authorRaw != null) {
      final authorId = authorRaw['id']?.toString() ?? '';
      final authorUserId = authorRaw['user_id']?.toString() ?? '';
      final authorName = authorRaw['name']?.toString() ?? '';
      final authorUsername = authorRaw['username']?.toString() ?? '';
      final authorEmail = authorRaw['email']?.toString() ?? '';

      if (loggedInUserId.isNotEmpty && authorId.isNotEmpty && loggedInUserId == authorId) {
        return true;
      }
      if (loggedInUserId.isNotEmpty && authorUserId.isNotEmpty && loggedInUserId == authorUserId) {
        return true;
      }
      if (loggedInUserName.isNotEmpty && authorName.isNotEmpty && authorName.toLowerCase() == loggedInUserName.toLowerCase()) {
        return true;
      }
      if (loggedInUserUsername.isNotEmpty && authorUsername.isNotEmpty && authorUsername.toLowerCase() == loggedInUserUsername.toLowerCase()) {
        return true;
      }
      if (loggedInUserEmail.isNotEmpty && authorEmail.isNotEmpty && authorEmail.toLowerCase() == loggedInUserEmail.toLowerCase()) {
        return true;
      }

      // Check nested profile key if available
      if (authorRaw['profile'] is Map) {
        final profileMap = authorRaw['profile'] as Map<String, dynamic>;
        final profileUserId = profileMap['user_id']?.toString() ?? '';
        final profileUsername = profileMap['username']?.toString() ?? '';

        if (loggedInUserId.isNotEmpty && profileUserId.isNotEmpty && loggedInUserId == profileUserId) {
          return true;
        }
        if (loggedInUserUsername.isNotEmpty && profileUsername.isNotEmpty && profileUsername.toLowerCase() == loggedInUserUsername.toLowerCase()) {
          return true;
        }
      }
    }

    return false;
  }

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
