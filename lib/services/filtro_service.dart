import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;

class FiltroService {
  Future<List<dynamic>> getAnimalsPeso(String idRefugio) async {
    try {
      final uri = Uri.parse('${UrlApi.url}animales/$idRefugio/underweight');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> animales = data["items"] ?? [];

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
