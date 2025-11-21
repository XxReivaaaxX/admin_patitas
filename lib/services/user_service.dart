import 'dart:convert';
import 'dart:developer';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserController {
  Future<bool> userActive() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<void> iniciarSesion(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error al iniciar sesión: $e");
    }
  }

  /// Cambiado para devolver bool
  Future<bool> registerUser(String email, String password) async {
    final uri = Uri.parse(UrlApi.url + "register");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password, 'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Inicia sesión automáticamente después del registro
        await iniciarSesion(email, password);
        print("Usuario registrado");
        return true;
      } else {
        print("Error al registrar usuario: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Excepción en registerUser: $e');
      return false;
    }
  }

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
}