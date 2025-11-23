import 'dart:convert';
import 'dart:developer';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  /// Inicia sesión en la API y guarda token en SharedPreferences
  Future<bool> iniciarSesion(String email, String password) async {
    final uri = Uri.parse('${UrlApi.url}login');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token en SharedPreferences
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          log('Token guardado correctamente');
        }

        log('Sesión iniciada correctamente');
        return true;
      } else {
        log('Error al iniciar sesión: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Excepción en iniciarSesion: $e');
      return false;
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
