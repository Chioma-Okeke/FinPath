import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _languageKey = 'language';
  static const _hasProfileKey = 'has_profile';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> saveLanguage(String lang) async {
    await _storage.write(key: _languageKey, value: lang);
  }

  static Future<String> getLanguage() async {
    return await _storage.read(key: _languageKey) ?? 'en';
  }

  static Future<void> saveUserProfileStatus(bool hasProfile) async {
    await _storage.write(key: _hasProfileKey, value: hasProfile.toString());
  }

  static Future<bool> getUserProfileStatus() async {
    final val = await _storage.read(key: _hasProfileKey);
    return val == 'true';
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAuth() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _languageKey);
    await _storage.delete(key: _hasProfileKey);
  }

  static Future<void> logout() async {
    await clearAuth();
  }

  
}
