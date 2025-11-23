class HistorialMedico {
  final String id;
  final String castrado;
  final String fechaRevision;
  final String enfermedades;
  final String tratamiento;
  final String peso;

  HistorialMedico({
    required this.id,
    required this.castrado,
    required this.fechaRevision,
    required this.enfermedades,
    required this.tratamiento,
    required this.peso,
  });

  factory HistorialMedico.fromJson(String id, Map<String, dynamic> json) {
    return HistorialMedico(
      id: id,
      castrado: json["castrado"],
      peso: json["peso"],
      fechaRevision: json["fecha_revision"],
      enfermedades: json["enfermedades"],
      tratamiento: json["tratamiento"],
    );
  }
}
