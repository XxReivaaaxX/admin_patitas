import 'package:admin_patitas/models/vacuna.dart';
import 'package:firebase_database/firebase_database.dart';

class VacunaService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Listas de vacunas predefinidas por especie
  static const List<String> vacunasPerros = [
    'Polivalente (Múltiple)',
    'Rabia',
    'Tos de las Perreras',
    'Coronavirus',
    'Leptospirosis',
    'Desparasitación',
  ];

  static const List<String> vacunasGatos = [
    'Triple Felina',
    'Rabia',
    'Leucemia Felina (FeLV)',
    'Clamidiosis',
    'Desparasitación',
  ];

  static const List<String> vacunasOtros = [
    'Rabia',
    'Desparasitación',
    'Otra (Personalizada)',
  ];

  // Obtener lista de vacunas según especie
  static List<String> getVacunasPorEspecie(String especie) {
    final especieLower = especie.toLowerCase();
    if (especieLower == 'perro' || especieLower == 'canino') {
      return vacunasPerros;
    } else if (especieLower == 'gato' || especieLower == 'felino') {
      return vacunasGatos;
    } else {
      return vacunasOtros;
    }
  }

  // Crear una nueva vacuna
  Future<void> createVacuna(
    String refugioId,
    String animalId,
    Vacuna vacuna,
  ) async {
    try {
      final vacunaRef = _database
          .child('animales')
          .child(refugioId)
          .child(animalId)
          .child('vacunas')
          .push();

      await vacunaRef.set(vacuna.toJson());
    } catch (e) {
      print('Error creando vacuna: $e');
      rethrow;
    }
  }

  // Obtener todas las vacunas de un animal
  Future<List<Vacuna>> getVacunas(String refugioId, String animalId) async {
    try {
      final snapshot = await _database
          .child('animales')
          .child(refugioId)
          .child(animalId)
          .child('vacunas')
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final List<Vacuna> vacunas = [];
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        vacunas.add(Vacuna.fromJson(value as Map<dynamic, dynamic>, key));
      });

      // Ordenar por fecha de aplicación (más reciente primero)
      vacunas.sort((a, b) {
        try {
          final fechaA = DateTime.parse(a.fecha);
          final fechaB = DateTime.parse(b.fecha);
          return fechaB.compareTo(fechaA);
        } catch (e) {
          return 0;
        }
      });

      return vacunas;
    } catch (e) {
      print('Error obteniendo vacunas: $e');
      return [];
    }
  }

  // Actualizar una vacuna
  Future<void> updateVacuna(
    String refugioId,
    String animalId,
    String vacunaId,
    Vacuna vacuna,
  ) async {
    try {
      await _database
          .child('animales')
          .child(refugioId)
          .child(animalId)
          .child('vacunas')
          .child(vacunaId)
          .update(vacuna.toJson());
    } catch (e) {
      print('Error actualizando vacuna: $e');
      rethrow;
    }
  }

  // Eliminar una vacuna
  Future<void> deleteVacuna(
    String refugioId,
    String animalId,
    String vacunaId,
  ) async {
    try {
      await _database
          .child('animales')
          .child(refugioId)
          .child(animalId)
          .child('vacunas')
          .child(vacunaId)
          .remove();
    } catch (e) {
      print('Error eliminando vacuna: $e');
      rethrow;
    }
  }

  // Obtener animales con vacunas próximas a vencer (30 días)
  Future<List<Map<String, dynamic>>> getAnimalesConVacunasProximas(
    String refugioId,
  ) async {
    try {
      final snapshot = await _database.child('animales').child(refugioId).get();

      if (!snapshot.exists) {
        return [];
      }

      final List<Map<String, dynamic>> resultado = [];
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var entry in data.entries) {
        final animalId = entry.key;
        final animalData = entry.value as Map<dynamic, dynamic>;

        if (animalData['vacunas'] != null) {
          final vacunasData = animalData['vacunas'] as Map<dynamic, dynamic>;

          for (var vacunaEntry in vacunasData.entries) {
            final vacuna = Vacuna.fromJson(
              vacunaEntry.value as Map<dynamic, dynamic>,
              vacunaEntry.key,
            );

            if (vacuna.isProximaAVencer() || vacuna.isVencida()) {
              resultado.add({
                'animalId': animalId,
                'animalNombre': animalData['nombre'] ?? 'Sin nombre',
                'vacuna': vacuna,
              });
            }
          }
        }
      }

      return resultado;
    } catch (e) {
      print('Error obteniendo animales con vacunas próximas: $e');
      return [];
    }
  }
}
