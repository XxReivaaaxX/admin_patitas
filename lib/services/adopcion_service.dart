import 'dart:developer';
import 'package:admin_patitas/models/animal.dart';
import 'package:firebase_database/firebase_database.dart';

class AdopcionService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Guardar un animal en la lista de adoptados/guardados del usuario
  Future<void> saveAnimal(
    String userId,
    String refugioId,
    Animal animal,
  ) async {
    try {
      final animalRef = _database
          .child('users')
          .child(userId)
          .child('adopciones_guardadas')
          .child(animal.id);

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
        'savedAt': ServerValue.timestamp,
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
      await _database
          .child('users')
          .child(userId)
          .child('adopciones_guardadas')
          .child(animalId)
          .remove();

      log("Animal eliminado de guardados: $animalId");
    } catch (e) {
      log('Error al eliminar animal de guardados: $e');
      rethrow;
    }
  }

  // Verificar si un animal ya está guardado
  Future<bool> isAnimalSaved(String userId, String animalId) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('adopciones_guardadas')
          .child(animalId)
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
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('adopciones_guardadas')
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> savedAnimals = [];

        data.forEach((key, value) {
          final animalData = Map<String, dynamic>.from(value as Map);
          savedAnimals.add(animalData);
        });

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
