import 'dart:async';
import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/notification_service.dart';
import 'package:firebase_database/firebase_database.dart';

class AnimalsService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> registerAnimals(String idRefugio, Animal animal) async {
    try {
      final newAnimalRef = _database.child('animales').child(idRefugio).push();

      await newAnimalRef.set({
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
      unawaited(
        NotificationsService().sendNotificationToCollaborators(
          refugioId: idRefugio,
          title: "Nuevo animal en el refugio",
          body: "",
          type: 'createAnimal',
          targetId: newAnimalRef.key!,
        ),
      );

      log("Animal registrado correctamente en Firebase: ${newAnimalRef.key}");
    } catch (e) {
      log('Error al registrar animal en Firebase: $e');
    }
  }

  Future<List<Animal>> getAnimals(String refugio) async {
    try {
      final snapshot = await _database.child('animales').child(refugio).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Animal> animals = [];

        data.forEach((key, value) {
          final animalData = Map<String, dynamic>.from(value as Map);
          animals.add(Animal.fromJson(key, animalData));
        });

        return animals;
      } else {
        log('No se encontraron animales para el refugio: $refugio');
        return [];
      }
    } catch (e) {
      log('Error al obtener animales de Firebase: $e');
      return [];
    }
  }

  Future<void> updateAnimals(String refugio, Animal animal) async {
    try {
      if (animal.id.isEmpty) {
        log('Error: ID del animal vacío, no se puede actualizar');
        return;
      }

      await _database.child('animales').child(refugio).child(animal.id).update({
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

      log("Animal actualizado correctamente en Firebase: ${animal.id}");
    } catch (e) {
      log('Error al actualizar animal en Firebase: $e');
    }
  }

  Future<Animal?> getAnimalById(String refugio, String animalId) async {
    try {
      if (animalId.isEmpty) {
        log('Error: ID del animal vacío');
        return null;
      }

      final snapshot = await _database
          .child('animales')
          .child(refugio)
          .child(animalId)
          .get();

      if (!snapshot.exists) {
        log('Animal no encontrado');
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      final animal = Animal(
        id: animalId,
        nombre: data['nombre'] ?? '',
        especie: data['especie'] ?? '',
        raza: data['raza'] ?? '',
        genero: data['sexo'] ?? '',
        historialMedicoId: data['historial_medico_id'] ?? '',
        estadoSalud: data['estado_salud'] ?? '',
        fechaIngreso: data['fecha_ingreso'] ?? '',
        estadoAdopcion: data['estado_adopcion'] ?? '',
        imageUrl: data['imagenUrl'] ?? '',
      );

      return animal;
    } catch (e) {
      log('Error al obtener animal de Firebase: $e');

      return null;
    }
  }

  Future<void> deleteAnimals(String refugio, Animal animal) async {
    try {
      if (animal.id.isEmpty) {
        log('Error: ID del animal vacío, no se puede eliminar');
        return;
      }

      await _database
          .child('animales')
          .child(refugio)
          .child(animal.id)
          .remove();

      log("Animal eliminado correctamente de Firebase: ${animal.id}");
    } catch (e) {
      log('Error al eliminar animal de Firebase: $e');
    }
  }

  Future<List<Animal>> filterAnimals(
    String refugio, {
    String searchQuery = '',
    String? especie,
    String? estadoSalud,
    String? estadoAdopcion,
    String? genero,
  }) async {
    final animals = await getAnimals(refugio);

    return animals.where((animal) {
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          animal.nombre.toLowerCase().contains(query) ||
          animal.raza.toLowerCase().contains(query);

      final matchesEspecie = especie == null || animal.especie == especie;
      final matchesSalud =
          estadoSalud == null || animal.estadoSalud == estadoSalud;
      final matchesAdopcion =
          estadoAdopcion == null || animal.estadoAdopcion == estadoAdopcion;
      final matchesGenero = genero == null || animal.genero == genero;

      return matchesSearch &&
          matchesEspecie &&
          matchesSalud &&
          matchesAdopcion &&
          matchesGenero;
    }).toList();
  }

  Future<List<Animal>> getAnimalsAvailable(String refugio) async {
    try {
      // Nueva Query que busca exclusivamente los que están en estado "Disponible"
      final snapshot = await _database
          .child('animales')
          .child(refugio)
          .orderByChild('estado_adopcion')
          .equalTo('Disponible')
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<Animal> animals = [];

        data.forEach((key, value) {
          final animalData = Map<String, dynamic>.from(value as Map);
          animals.add(Animal.fromJson(key, animalData));
        });

        return animals;
      } else {
        log(
          'No se encontraron animales con estado Disponible en el refugio: $refugio',
        );
        return [];
      }
    } catch (e) {
      log('Error al obtener animales disponibles de Firebase: $e');
      return [];
    }
  }
}
