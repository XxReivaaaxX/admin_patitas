import 'package:firebase_auth/firebase_auth.dart';

class Usuario {
  final String? id;
  final String? email;

  Usuario({required this.id, required this.email});

  factory Usuario.getUsuario(User user) {
    return Usuario(id: user.uid, email: user.email);
  }
}
