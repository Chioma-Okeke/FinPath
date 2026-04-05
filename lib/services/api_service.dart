import 'dart:convert';
import 'package:finpath/models/onboarding_options_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator (maps to host machine's localhost)
  static const String _baseUrl = 'https://finpath-nx82.onrender.com';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
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
        ...?(email != null ? {'email': email} : null),
        ...?(password != null ? {'password': password} : null),
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
    String name, {
    String? password,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        ...?(password != null ? {'password': password} : null),
      }),
    );
    return jsonDecode(res.body);
  }

  // Onboarding
  static Future<Map<String, dynamic>> submitOnboarding(
    Map<String, dynamic> answers,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding'),
      headers: await _authHeaders(),
      body: jsonEncode(answers),
    );
    return jsonDecode(res.body);
  }

  // Snapshot
  static Future<Map<String, dynamic>> getSnapshot() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/snapshot'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body);
  }

  // Actions
  static Future<List<dynamic>> getActions() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/actions'),
      headers: await _authHeaders(),
    );
    final decoded = jsonDecode(res.body);
    debugPrint('ACTIONS RAW: $decoded');
    if (decoded is List) return decoded;
    if (decoded is Map) {
      // Handle wrapped responses: {"actions": [...]} or {"data": [...]}
      for (final key in ['actions', 'data', 'items', 'results']) {
        if (decoded[key] is List) return decoded[key] as List<dynamic>;
      }
    }
    return [];
  }

  static Future<Map<String, dynamic>> completeAction(int actionId) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/actions/$actionId'),
      headers: await _authHeaders(),
      body: jsonEncode({'is_completed': true}),
    );
    return jsonDecode(res.body);
  }

  // AI Assistant
  static Future<String> askAI(String question) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/ai/ask'),
      headers: await _authHeaders(),
      body: jsonEncode({'question': question}),
    );
    final data = jsonDecode(res.body);
    return data['answer'] ?? '';
  }

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
