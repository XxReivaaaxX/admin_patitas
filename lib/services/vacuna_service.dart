import 'dart:developer';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VacunaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore
          .collection('refugios')
          .doc(refugioId)
          .collection('animales')
          .doc(animalId)
          .collection('vacunas')
          .add(vacuna.toJson());
    } catch (e) {
      log('Error creando vacuna en Firestore: $e');
      rethrow;
    }
  }

  // Obtener todas las vacunas de un animal
  Future<List<Vacuna>> getVacunas(String refugioId, String animalId) async {
    try {
      final snapshot = await _firestore
          .collection('refugios')
          .doc(refugioId)
          .collection('animales')
          .doc(animalId)
          .collection('vacunas')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<Vacuna> vacunas = snapshot.docs.map((doc) {
        return Vacuna.fromJson(doc.data(), doc.id);
      }).toList();

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
      log('Error obteniendo vacunas de Firestore: $e');
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
      await _firestore
          .collection('refugios')
          .doc(refugioId)
          .collection('animales')
          .doc(animalId)
          .collection('vacunas')
          .doc(vacunaId)
          .update(vacuna.toJson());
    } catch (e) {
      log('Error actualizando vacuna en Firestore: $e');
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
      await _firestore
          .collection('refugios')
          .doc(refugioId)
          .collection('animales')
          .doc(animalId)
          .collection('vacunas')
          .doc(vacunaId)
          .delete();
    } catch (e) {
      log('Error eliminando vacuna en Firestore: $e');
      rethrow;
    }
  }

  // Obtener animales con vacunas próximas a vencer (30 días)
  Future<List<Map<String, dynamic>>> getAnimalesConVacunasProximas(
    String refugioId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('refugios')
          .doc(refugioId)
          .collection('animales')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> resultado = [];

      for (var doc in snapshot.docs) {
        final animalId = doc.id;
        final animalData = doc.data();
        
        // Fetch vacunas for each animal
        final vacunasSnapshot = await doc.reference.collection('vacunas').get();

        if (vacunasSnapshot.docs.isNotEmpty) {
          for (var vacunaDoc in vacunasSnapshot.docs) {
            final vacuna = Vacuna.fromJson(vacunaDoc.data(), vacunaDoc.id);

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
      log('Error obteniendo animales con vacunas próximas en Firestore: $e');
      return [];
    }
  }
}
