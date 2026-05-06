import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/models/refugio.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RefugioController {
  Future<List<Refugio>> getRefugios(String idUser) async {
    try {
      final uri = Uri.parse('${UrlApi.url}refugios/$idUser');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        uri,
        headers: token == null ? {} : {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        log('datos obtenidos:  ${response.body}');
        final Map<String, dynamic> payload = jsonDecode(response.body);
        final Map<String, dynamic> refugiosMap = Map<String, dynamic>.from(
          payload['items'] ?? {},
        );

        final List<Refugio> refugios = refugiosMap.entries.map((entry) {
          final id = entry.key;
          final value = entry.value as Map<String, dynamic>;

          return Refugio.fromJson(id, value);
        }).toList();

        return refugios;
      } else {
        throw Exception('error al cargar datos');
      }
    } catch (e) {
      throw Exception('error al cargar datos');
    }
  }
}
