import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;

class AnimalsService {
  Future<void> registerAnimals(String id_refugio, Animal animal) async {
    try {
      final uri = Uri.parse(UrlApi.url + "registro-animal");

      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_refugio': id_refugio,
          'nombre': animal.nombre,
          'especie': animal.especie,
          'raza': animal.raza,
          'sexo': animal.genero,
          'historial_medico_id': animal.historialMedicoId,
          'estado_salud': animal.estadoSalud,
          'fecha_ingreso': animal.fechaIngreso,
        }),
      );

      log("Animal enviado correctamente, historial medico");
    } catch (e) {
      log('error al enviar los datos de animales $e');
    }
  }

  Future<List<Animal>> getAnimals(String refugio) async {
    try {
      final uri = Uri.parse(UrlApi.url + "animales/" + refugio);
      final response = await http.get(uri);
      final Map<String, dynamic> _animal = jsonDecode(response.body);

      if (response.statusCode == 200) {
        log('datos obtenidos:  ${response.body}');

        final List<Animal> animals = _animal.entries.map((entry) {
          final id = entry.key;
          final value = entry.value as Map<String, dynamic>;
          return Animal.fromJson(id, value);
        }).toList();

        return animals;
      } else {
        log('error al obtener los datos de animales');
        return [];
      }
    } catch (e) {
      log('error al obtener en la funcion par aobtener datos de animales $e');
      throw Exception('error al caregar datos');
    }
  }

  Future<void> updateAnimals(String refugio, Animal animal) async {
    try {
      final uri = Uri.parse(UrlApi.url + "update-animal");

      if (animal.historialMedicoId != '') {
        await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_refugio': refugio,
            'id_animal': animal.id,
            'nombre': animal.nombre,
            'especie': animal.especie,
            'raza': animal.raza,
            'sexo': animal.genero,
            'historial_medico_id': animal.historialMedicoId,
            'estado_salud': animal.estadoSalud,
            'fecha_ingreso': animal.fechaIngreso,
          }),
        );
      } else {
        log('faltan datos de historial medico para actualizar el animal');
      }

      log("Animal actualizado correctamente");
    } catch (e) {
      log('error al actualizar los datos de animales $e');
    }
  }

  Future<void> deleteAnimals(String refugio, Animal animal) async {
    try {
      final uri = Uri.parse(UrlApi.url + "delete-animal");

      if (animal.id != '') {
        await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_refugio': refugio,
            'id_animal': animal.id,
            'historial_medico_id': animal.historialMedicoId,
          }),
        );
        log("Animal eliminado correctamente");
      } else {
        log('faltan datos de animal para eliminar el animal');
      }
    } catch (e) {
      log('error al actualizar los datos de animales $e');
    }
  }
}
