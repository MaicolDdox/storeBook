import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ajusta según tu entorno
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Guardar token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper headers
  static Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 201) {
      // guardar token
      final token = body['token'] as String?;
      if (token != null) await saveToken(token);
      return {'ok': true, 'data': body};
    } else {
      return {'ok': false, 'error': body};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? device,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password, 'device': device}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final token = body['token'] as String?;
      if (token != null) await saveToken(token);
      return {'ok': true, 'data': body};
    } else {
      return {'ok': false, 'error': body};
    }
  }

  // Obtener usuario logueado / me
  static Future<Map<String, dynamic>> me() async {
    final uri = Uri.parse('$baseUrl/me');
    final res = await http.get(uri, headers: await _headers(withAuth: true));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return {'ok': true, 'user': body};
    } else {
      return {'ok': false, 'error': body};
    }
  }

  // Logout (revocar token)
  static Future<Map<String, dynamic>> logout() async {
    final uri = Uri.parse('$baseUrl/auth/logout');
    final res = await http.post(uri, headers: await _headers(withAuth: true));
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await clearToken();
      return {'ok': true, 'data': body};
    } else {
      return {'ok': false, 'error': body};
    }
  }
}
