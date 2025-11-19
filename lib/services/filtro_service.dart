import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/refugio.dart';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;

class FiltroService {
  Future<List<dynamic>> getAnimalsPeso(String id_refugio) async {
    try {
      final uri = Uri.parse(UrlApi.url + "animales/" + id_refugio);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> animales = data["animales_bajo_peso"] ?? [];

        log('animales bajo peso: $animales');

        return animales;
      } else {
        throw Exception('Error al cargar datos');
      }
    } catch (e) {
      throw Exception('Error al cargar datos');
    }
  }
}
