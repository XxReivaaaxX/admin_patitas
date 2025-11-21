import 'dart:convert';
import 'dart:developer';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  /// Inicia sesión en la API y devuelve códigos específicos
  Future<String> iniciarSesion(String email, String password) async {
    final uri = Uri.parse('${UrlApi.url}login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      log('Código de respuesta: ${response.statusCode}');
      log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        // Login exitoso
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          log('Token guardado correctamente');
        }
        log('Sesión iniciada correctamente');
        return "success";
      }

      // Usuario no encontrado (status o mensaje en body)
      if (response.statusCode == 404 ||
          response.statusCode == 400 ||
          response.body.toLowerCase().contains("usuario no encontrado") ||
          response.body.toLowerCase().contains("user not found")) {
        return "user_not_found";
      }

      // Credenciales incorrectas
      if (response.statusCode == 401 ||
          response.body.toLowerCase().contains("contraseña incorrecta") ||
          response.body.toLowerCase().contains("invalid credentials")) {
        return "invalid_credentials";
      }

      // Otro error
      return "error";
    } catch (e) {
      log('Excepción en iniciarSesion: $e');
      return "error";
    }
  }

  /// Registra usuario en la API
  Future<bool> registerUser(String email, String password) async {
    final uri = Uri.parse('${UrlApi.url}register');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Usuario registrado correctamente en API');
        return true;
      } else {
        log('Error al registrar usuario: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Excepción en registerUser: $e');
      return false;
    }
  }

  /// Obtiene datos del usuario desde la API
  Future<Usuario> getUsuario(String id_user) async {
    final uri = Uri.parse('${UrlApi.url}usuarios/$id_user');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      log('Usuario obtenido: ${response.body}');
      final data = jsonDecode(response.body);
      return Usuario.getUsuario(data);
    } else {
      throw Exception('Error al cargar los datos del usuario');
    }
  }

  /// Cierra sesión y elimina token
  Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    log('Sesión cerrada correctamente');
  }

  /// Verifica si hay token guardado
  Future<bool> verificarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}
