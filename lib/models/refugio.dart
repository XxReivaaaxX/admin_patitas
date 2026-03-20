class Refugio {
  final String id;
  final String idUsuario;
  final String nombre;
  final String direccion;

  Refugio({
    required this.id,
    required this.idUsuario,
    required this.nombre,
    required this.direccion,
  });

  factory Refugio.fromJson(String id, Map<String, dynamic> json) {
    return Refugio(
      id: id,
      idUsuario: json["id_usuario"],
      nombre: json["nombre"],
      direccion: json["direccion"],
    );
  }
}
