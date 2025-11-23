class Animal {
  final String id;
  final String especie;
  final String raza;
  final String historialMedicoId;
  final String estadoSalud;
  final String fechaIngreso;
  final String nombre;
  final String genero;
  final String estadoAdopcion;
  final String imageUrl;
  //final String imagenUrl; // NUEVO

  Animal({
    required this.id,
    required this.raza,
    required this.especie,
    required this.estadoSalud,
    required this.fechaIngreso,
    required this.historialMedicoId,
    required this.nombre,
    required this.genero,
    this.estadoAdopcion = 'No Disponible',
    this.imageUrl = '',
  });

  factory Animal.fromJson(String id, Map<String, dynamic> json) {
    return Animal(
      id: id,
      raza: json["raza"],
      especie: json["especie"],
      estadoSalud: json["estado_salud"],
      historialMedicoId: json["historial_medico_id"],
      fechaIngreso: json["fecha_ingreso"],
      nombre: json["nombre"],
      genero: json["sexo"],
      //imagenUrl: json['imagenUrl'] ?? '',
      estadoAdopcion: json["estado_adopcion"] ?? 'No Disponible',
      imageUrl: json["imagenUrl"] ?? '',
    );
  }
  /*
    Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'especie': especie,
    'raza': raza,
    'sexo': genero,
    'estado_salud': estadoSalud,
    'fecha_ingreso': fechaIngreso,
    'id': id,
    'historial_medico_id': historialMedicoId,
    'imagenUrl': imagenUrl,
  };*/
}
