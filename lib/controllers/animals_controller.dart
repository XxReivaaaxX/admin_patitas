import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:http/http.dart' as http;

class AnimalsController {
  final String url = 'http://localhost:5000/';

  Future<List<Animal>> getAnimals(String refugio) async {
    try {
      final uri = Uri.parse(url + "animales/" + refugio);
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
      log('error al obtener los datos de animales $e');
      return [];
    }
  }
}
