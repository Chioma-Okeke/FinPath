import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _languageKey = 'language';
  static const _hasProfileKey = "false";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> saveLanguage(String lang) async {
    await _storage.write(key: _languageKey, value: lang);
  }

  static Future<String> getLanguage() async {
    return await _storage.read(key: _languageKey) ?? 'en';
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<void> saveUserProfileStatus(bool hasProfile) async {
    await _storage.write(
      key: _hasProfileKey,
      value: hasProfile.toString(), // "true" or "false"
    );
  }

  static Future<bool> getUserProfileStatus() async {
    final val = await _storage.read(key: _hasProfileKey);
    return val == 'true';
  }

  static Future<int?> getUserProfile() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }
}
