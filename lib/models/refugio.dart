import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/models/usuario.dart';

class Refugio {
  final String id;
  final String id_usuario;
  final String nombre;
  final String direccion;

  Refugio({
    required this.id,
    required this.id_usuario,
    required this.nombre,
    required this.direccion,
  });

  factory Refugio.fromJson(String id, Map<String, dynamic> json) {
    return Refugio(
      id: id,
      id_usuario: json["id_usuario"],
      nombre: json["nombre"],
      direccion: json["direccion"],
    );
  }
}
