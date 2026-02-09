import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';

/// Servicio base para realizar peticiones HTTP a la API en Laravel 12.
/// Unifica autenticación, encabezados, manejo de token y métodos REST.
/// Está diseñado para ser profesional, escalable y fácil de mantener.
class ApiService {
  /// URL base de la API Laravel.

  static String baseUrl = AppConfig.apiBaseUrl;

  // ---------------------------------------------------------------
  // MÉTODOS PRIVADOS BASE
  // ---------------------------------------------------------------

  Future<String?> _obtenerToken() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString("token");
  }

  /// Construye los encabezados dependiendo de si la petición requiere autenticación.
  Future<Map<String, String>> _construirEncabezados({bool requiereAuth = false}) async {
    final encabezados = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (requiereAuth) {
      final token = await _obtenerToken();
      if (token != null) {
        encabezados["Authorization"] = "Bearer $token";
      }
    }

    return encabezados;
  }

  /// Método POST exclusivo para login/register (privado).
  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> data,
      {bool auth = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _construirEncabezados(requiereAuth: auth);

    try {
      final respuesta = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      return jsonDecode(respuesta.body);
    } catch (e) {
      return {
        "error": true,
        "message": "Error de conexión: $e",
      };
    }
  }

  // ---------------------------------------------------------------
  // MÉTODOS REST PÚBLICOS (estos usan todos los demás servicios)
  // ---------------------------------------------------------------

  /// Realiza una petición GET genérica.
  Future<dynamic> get(String endpoint, {bool auth = false}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _construirEncabezados(requiereAuth: auth);

    final respuesta = await http.get(url, headers: headers);
    if (respuesta.body.isEmpty) return null;

    return jsonDecode(respuesta.body);
  }

  /// Realiza una petición POST pública,
  /// utilizada por servicios como carrito o factura.
  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data, {
        bool auth = false,
      }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _construirEncabezados(requiereAuth: auth);

    final respuesta =
    await http.post(url, headers: headers, body: jsonEncode(data));

    if (respuesta.body.isEmpty) return null;
    return jsonDecode(respuesta.body);
  }

  /// Realiza una petición DELETE genérica.
  Future<dynamic> delete(
      String endpoint, {
        bool auth = false,
      }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final headers = await _construirEncabezados(requiereAuth: auth);

    final respuesta = await http.delete(url, headers: headers);
    if (respuesta.body.isEmpty) return null;

    return jsonDecode(respuesta.body);
  }

  // ---------------------------------------------------------------
  // AUTENTICACIÓN (usa el método privado _post)
  // ---------------------------------------------------------------

  /// Registro de usuario en Laravel.
  Future<Map<String, dynamic>> register(
      String name, String email, String password) {
    return _post("/auth/register", {
      "name": name,
      "email": email,
      "password": password,
    });
  }

  /// Inicio de sesión con Laravel Sanctum.
  Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await _post("/auth/login", {
      "email": email,
      "password": password,
      "device": "windows-app",
    });

    if (response["token"] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", response["token"]);
    }

    return response;
  }

  /// Logout seguro (revoca el token en Laravel y lo elimina en Flutter).
  Future<void> logout() async {
    await _post("/auth/logout", {}, auth: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  /// Obtiene la información del usuario autenticado desde Laravel.
  Future<Map<String, dynamic>?> obtenerUsuarioActual() async {
    final respuesta = await get("/me", auth: true);

    if (respuesta is Map<String, dynamic> && respuesta["id"] != null) {
      return respuesta;
    }

    return null;
  }

}
