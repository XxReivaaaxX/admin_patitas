import 'dart:convert';
import 'dart:developer';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  /// ✅ Verifica si hay sesión activa en Firebase
  Future<bool> userActive() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  /// ✅ Inicia sesión con Firebase y guarda token en SharedPreferences
  Future<bool> iniciarSesion(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar token en SharedPreferences
      final token = await credential.user?.getIdToken();
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        log('Token guardado correctamente');
      }

      log('Sesión iniciada correctamente');
      return true;
    } catch (e) {
      log("Error al iniciar sesión: $e");
      return false;
    }
  }

  /// Registra usuario en API y Firebase, devuelve true si todo ok
  Future<bool> registerUser(String email, String password) async {
    final uri = Uri.parse(UrlApi.url + "register");

    try {
      // Registro en API
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password, 'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registro en Firebase
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Inicia sesión automáticamente
        await iniciarSesion(email, password);

        log("Usuario registrado y sesión iniciada correctamente");
        return true;
      } else {
        log("Error al registrar usuario: ${response.body}");
        return false;
      }
    } catch (e) {
      log('Excepción en registerUser: $e');
      return false;
    }
  }

  /// Obtiene datos del usuario desde la API
  Future<Usuario> getUsuario(String id_user) async {
    final uri = Uri.parse(UrlApi.url + 'usuarios/' + id_user);
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
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      log('Sesión cerrada correctamente');
    } catch (e) {
      log('Error al cerrar sesión: $e');
    }
  }

  /// Verifica si hay token guardado
  Future<bool> verificarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}