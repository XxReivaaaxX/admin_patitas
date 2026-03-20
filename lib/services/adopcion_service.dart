import 'dart:developer';
import 'package:admin_patitas/models/animal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdopcionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guardar un animal en la lista de adoptados/guardados del usuario
  Future<void> saveAnimal(
    String userId,
    String refugioId,
    Animal animal,
  ) async {
    try {
      final animalRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('adopciones_guardadas')
          .doc(animal.id);

      await animalRef.set({
        'refugioId': refugioId,
        'animalId': animal.id,
        'nombre': animal.nombre,
        'especie': animal.especie,
        'raza': animal.raza,
        'sexo': animal.genero,
        'estadoSalud': animal.estadoSalud,
        'fechaIngreso': animal.fechaIngreso,
        'estadoAdopcion': animal.estadoAdopcion,
        'savedAt': FieldValue.serverTimestamp(),
      });

      log("Animal guardado correctamente: ${animal.nombre}");
    } catch (e) {
      log('Error al guardar animal: $e');
      rethrow;
    }
  }

  // Eliminar un animal de la lista de guardados
  Future<void> removeAnimal(String userId, String animalId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('adopciones_guardadas')
          .doc(animalId)
          .delete();

      log("Animal eliminado de guardados: $animalId");
    } catch (e) {
      log('Error al eliminar animal de guardados: $e');
      rethrow;
    }
  }

  // Verificar si un animal ya está guardado
  Future<bool> isAnimalSaved(String userId, String animalId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('adopciones_guardadas')
          .doc(animalId)
          .get();

      return snapshot.exists;
    } catch (e) {
      log('Error al verificar animal guardado: $e');
      return false;
    }
  }

  // Obtener todos los animales guardados por el usuario
  Future<List<Map<String, dynamic>>> getSavedAnimals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('adopciones_guardadas')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> savedAnimals = [];

        for (var doc in snapshot.docs) {
          savedAnimals.add(doc.data());
        }

        return savedAnimals;
      } else {
        return [];
      }
    } catch (e) {
      log('Error al obtener animales guardados: $e');
      return [];
    }
  }
}
