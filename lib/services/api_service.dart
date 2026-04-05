import 'dart:convert';
import 'package:finpath/models/onboarding_options_response.dart';
import 'package:finpath/models/resource.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'https://finpath-nx82.onrender.com';

  // ---------------------------
  // Core auth helpers
  // ---------------------------

  static Future<Map<String, String>> _authHeaders() async {
    final accessToken = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<bool> refreshAccessToken() async {
    final refreshToken = await AuthService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (res.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final newAccessToken = data['access_token'] as String?;

    if (newAccessToken == null || newAccessToken.isEmpty) {
      return false;
    }

    await AuthService.saveAccessToken(newAccessToken);
    return true;
  }

  static Future<http.Response> _authorizedGet(String path) async {
    var res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _authHeaders(),
    );

    if (res.statusCode == 401) {
      final refreshed = await refreshAccessToken();

      if (!refreshed) {
        await AuthService.logout();
        return res;
      }

      res = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(),
      );
    }

    return res;
  }

  static Future<http.Response> _authorizedPost(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    var res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _authHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );

    if (res.statusCode == 401) {
      final refreshed = await refreshAccessToken();

      if (!refreshed) {
        await AuthService.logout();
        return res;
      }

      res = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
    }

    return res;
  }

  static Future<http.Response> _authorizedPatch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    var res = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _authHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );

    if (res.statusCode == 401) {
      final refreshed = await refreshAccessToken();

      if (!refreshed) {
        await AuthService.logout();
        return res;
      }

      res = await http.patch(
        Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
    }

    return res;
  }

  // ---------------------------
  // Auth
  // ---------------------------

  static Future<Map<String, dynamic>> register(
    String name,
    String language, {
    String? email,
    String? password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'language': language,
        'email': ?email,
        'password': ?password,
      }),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data['access_token'] != null) {
        await AuthService.saveAccessToken(data['access_token']);
      }
      if (data['refresh_token'] != null) {
        await AuthService.saveRefreshToken(data['refresh_token']);
      }
      if (data['user_id'] != null) {
        await AuthService.saveUserId(data['user_id'].toString());
      }
      if (data['language'] != null) {
        await AuthService.saveLanguage(data['language']);
      }
      if (data['has_profile'] != null) {
        await AuthService.saveUserProfileStatus(data['has_profile'] == true);
      }
    }

    return data;
  }

  static Future<Map<String, dynamic>> login(
    String email, {
    String? password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': ?password,
      }),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (data['access_token'] != null) {
        await AuthService.saveAccessToken(data['access_token']);
      }
      if (data['refresh_token'] != null) {
        await AuthService.saveRefreshToken(data['refresh_token']);
      }
      if (data['user_id'] != null) {
        await AuthService.saveUserId(data['user_id'].toString());
      }
      if (data['language'] != null) {
        await AuthService.saveLanguage(data['language']);
      }
      if (data['has_profile'] != null) {
        await AuthService.saveUserProfileStatus(data['has_profile'] == true);
      }
    }

    return data;
  }

  // ---------------------------
  // Onboarding
  // ---------------------------

  static Future<Map<String, dynamic>> submitOnboarding(
    Map<String, dynamic> answers,
  ) async {
    final res = await _authorizedPost(
      '/onboarding',
      body: answers,
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    return data;
  }

  // ---------------------------
  // Snapshot
  // ---------------------------

  static Future<Map<String, dynamic>> getSnapshot() async {
    final res = await _authorizedGet('/snapshot');
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    return data;
  }

  // ---------------------------
  // Actions
  // ---------------------------

  static Future<List<dynamic>> getActions() async {
    final res = await _authorizedGet('/actions');

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    final decoded = jsonDecode(res.body);
    debugPrint('ACTIONS RAW: $decoded');

    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      for (final key in ['actions', 'data', 'items', 'results']) {
        if (decoded[key] is List) {
          return decoded[key] as List<dynamic>;
        }
      }
    }

    return [];
  }
  static Future<List<dynamic>> getCompletedActions () async {
    final res = await _authorizedGet('/actions/completed');

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    final decoded = jsonDecode(res.body);
    debugPrint('ACTIONS RAW: $decoded');

    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      for (final key in ['actions', 'data', 'items', 'results']) {
        if (decoded[key] is List) {
          return decoded[key] as List<dynamic>;
        }
      }
    }

    return [];
  }

  static Future<Map<String, dynamic>> completeAction(String actionKey) async {
    final res = await _authorizedPatch(
      '/actions/$actionKey',
      body: {'is_completed': true},
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    return data;
  }

  // ---------------------------
  // AI Assistant
  // ---------------------------

  static Future<String> askAI(String question) async {
    final res = await _authorizedPost(
      '/ai/ask',
      body: {'question': question},
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    return data['answer'] ?? '';
  }

  // ---------------------------
  // User
  // ---------------------------

  static Future<Map<String, dynamic>> getMe() async {
    final res = await _authorizedGet('/auth/me');

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> updateLanguage(String language) async {
    final res = await _authorizedPatch(
      '/profile',
      body: {'language': language},
    );

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update language.');
    }
  }

  // ---------------------------
  // Resources
  // ---------------------------

  static Future<List<dynamic>> getResources() async {
    final res = await _authorizedGet('/resources');

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    final decoded = jsonDecode(res.body);

    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      for (final key in ['resources', 'data', 'items', 'results']) {
        if (decoded[key] is List) {
          return decoded[key] as List<dynamic>;
        }
      }
    }

    return [];
  }

  static Future<Resource> getResource(String resourceId) async {
    final res = await _authorizedGet('/resources/$resourceId');

    if (res.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }

    if (res.statusCode != 200) {
      throw Exception('Resource not found');
    }

    return Resource.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ---------------------------
  // Meta
  // ---------------------------

  static Future<OnboardingOptionsResponse> getOnboardingOptions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/meta/onboarding-options'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load onboarding options');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return OnboardingOptionsResponse.fromJson(data);
  }
}