import 'dart:convert';
import 'dart:developer';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  /// Inicia sesión en la API y guarda token en SharedPreferences
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
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

  /// Registra un nuevo usuario en Firebase Auth y guarda datos en Realtime Database
  Future<bool> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        DatabaseReference userRef = _database
            .ref()
            .child('users')
            .child(user.uid);

        await userRef.set({
          'email': email,
          'registered_at': DateTime.now().toIso8601String(),
        });

        log('Usuario registrado: ${user.uid}');
        return true;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      log('Error de Firebase Auth: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      log('Excepción general en registerUser: $e');
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
