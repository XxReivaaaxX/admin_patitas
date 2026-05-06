import 'package:firebase_auth/firebase_auth.dart';

class Usuario {
  final String? id;
  final String? email;

  Usuario({required this.id, required this.email});

  factory Usuario.fromFirebaseUser(User user) {
    return Usuario(id: user.uid, email: user.email);
  }

  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      id: (data['uid'] ?? data['id'])?.toString(),
      email: data['email']?.toString(),
    );
  }
}
