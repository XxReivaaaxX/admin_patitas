class Vacunas {
  final String id;
  final String nombre;
  final String fecha;

  Vacunas({required this.id, required this.nombre, required this.fecha});

  factory Vacunas.fromJson(String id, Map<String, dynamic> json) {
    return Vacunas(id: id, nombre: json["nombre"], fecha: json["fecha"]);
  }
}
