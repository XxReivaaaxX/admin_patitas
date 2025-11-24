class Vacuna {
  final String id;
  final String nombre;
  final String fecha; // Fecha de aplicación (ISO 8601)
  final String proximaFecha; // Fecha del próximo refuerzo (ISO 8601)
  final String veterinario;
  final String lote;
  final String observaciones;
  final int timestamp;

  Vacuna({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.proximaFecha,
    required this.veterinario,
    required this.lote,
    required this.observaciones,
    required this.timestamp,
  });

  // Crear desde JSON (Firebase)
  factory Vacuna.fromJson(Map<dynamic, dynamic> json, String id) {
    return Vacuna(
      id: id,
      nombre: json['nombre'] ?? '',
      fecha: json['fecha'] ?? '',
      proximaFecha: json['proximaFecha'] ?? '',
      veterinario: json['veterinario'] ?? '',
      lote: json['lote'] ?? '',
      observaciones: json['observaciones'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Convertir a JSON para Firebase
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'fecha': fecha,
      'proximaFecha': proximaFecha,
      'veterinario': veterinario,
      'lote': lote,
      'observaciones': observaciones,
      'timestamp': timestamp,
    };
  }

  // Verificar si la vacuna está próxima a vencer (30 días)
  bool isProximaAVencer() {
    if (proximaFecha.isEmpty) return false;
    try {
      final proxima = DateTime.parse(proximaFecha);
      final ahora = DateTime.now();
      final diferencia = proxima.difference(ahora).inDays;
      return diferencia > 0 && diferencia <= 30;
    } catch (e) {
      return false;
    }
  }

  // Verificar si la vacuna está vencida
  bool isVencida() {
    if (proximaFecha.isEmpty) return false;
    try {
      final proxima = DateTime.parse(proximaFecha);
      return proxima.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Verificar si la vacuna está al día
  bool isAlDia() {
    if (proximaFecha.isEmpty)
      return true; // Si no hay próxima fecha, asumimos que está al día
    try {
      final proxima = DateTime.parse(proximaFecha);
      final ahora = DateTime.now();
      return proxima.isAfter(ahora) && proxima.difference(ahora).inDays > 30;
    } catch (e) {
      return false;
    }
  }
}
