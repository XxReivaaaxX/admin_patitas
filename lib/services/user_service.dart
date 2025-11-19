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
      final credential = FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("error al iniciar sesion $e");
    }
  }

  Future<void> registerUser(String email, String password) async {
    final UserController userController = UserController();
    final uri = Uri.parse(UrlApi.url + "register");

    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password, 'email': email}),
      );
      await userController.iniciarSesion(email, password);
      print("Usuario enviado correctamente");
    } catch (e) {
      print('Excepción de Flutter/Dart: $e');
    }
  }

  Future<Usuario> getUsuario(String id_user) async {
    final uri = Uri.parse(UrlApi.url + 'usuarios/' + id_user);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      log('Usuario obtenido: ${response.body}');
      final User data = jsonDecode(response.body);
      return Usuario.getUsuario(data);
    } else {
      throw Exception('Error al cargar los datos del usuario');
    }
  }

  /*
    var estado = false;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        estado = false;
        print('User is currently signed out!');
      } else {
        estado = true;
        print('User is signed in!');
      }
    });
    return estado;*/

  /*
  Future<void> registerUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('la contraseña no es segura.');
      } else if (e.code == 'email-already-in-use') {
        print('ya esta registrado este correo electronico.');
      }
    } catch (e) {
      print(e);
    }
  }*/
}
