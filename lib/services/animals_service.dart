import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerAnimals(String idRefugio, Animal animal) async {
    try {
      final newAnimalRef = await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .add({
        'nombre': animal.nombre,
        'especie': animal.especie,
        'raza': animal.raza,
        'sexo': animal.genero,
        'historial_medico_id': animal.historialMedicoId,
        'estado_salud': animal.estadoSalud,
        'fecha_ingreso': animal.fechaIngreso,
        'estado_adopcion': animal.estadoAdopcion,
        'imagenUrl': animal.imageUrl,
      });

      log("Animal registrado correctamente en Firestore: ${newAnimalRef.id}");
    } catch (e) {
      log('Error al registrar animal en Firestore: $e');
    }
  }

  Future<List<Animal>> getAnimals(String refugio) async {
    try {
      final snapshot = await _firestore
          .collection('refugios')
          .doc(refugio)
          .collection('animales')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<Animal> animals = snapshot.docs.map((doc) {
          final data = doc.data();
          return Animal.fromJson(doc.id, data);
        }).toList();

        return animals;
      } else {
        log('No se encontraron animales para el refugio: $refugio');
        return [];
      }
    } catch (e) {
      log('Error al obtener animales de Firestore: $e');
      return [];
    }
  }

  Future<void> updateAnimals(String refugio, Animal animal) async {
    try {
      if (animal.id.isEmpty) {
        log('Error: ID del animal vacío, no se puede actualizar');
        return;
      }

      await _firestore
          .collection('refugios')
          .doc(refugio)
          .collection('animales')
          .doc(animal.id)
          .update({
        'nombre': animal.nombre,
        'especie': animal.especie,
        'raza': animal.raza,
        'sexo': animal.genero,
        'historial_medico_id': animal.historialMedicoId,
        'estado_salud': animal.estadoSalud,
        'fecha_ingreso': animal.fechaIngreso,
        'estado_adopcion': animal.estadoAdopcion,
        'imagenUrl': animal.imageUrl,
      });

      log("Animal actualizado correctamente en Firestore: ${animal.id}");
    } catch (e) {
      log('Error al actualizar animal en Firestore: $e');
    }
  }

  Future<void> deleteAnimals(String refugio, Animal animal) async {
    try {
      if (animal.id.isEmpty) {
        log('Error: ID del animal vacío, no se puede eliminar');
        return;
      }

      await _firestore
          .collection('refugios')
          .doc(refugio)
          .collection('animales')
          .doc(animal.id)
          .delete();

      log("Animal eliminado correctamente de Firestore: ${animal.id}");
    } catch (e) {
      log('Error al eliminar animal de Firestore: $e');
    }
  }
}
