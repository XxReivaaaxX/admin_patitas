import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/refugio.dart';
import 'package:admin_patitas/models/usuario.dart';
import 'package:http/http.dart' as http;

class RefugioController {
  final String url = 'http://localhost:5000/';

  Future<List<Refugio>> getRefugios(String id_user) async {
    try {
      final uri = Uri.parse(url + "refugios/" + id_user);
      final response = await http.get(uri);
      final Map<String, dynamic> _refugio = jsonDecode(response.body);

      if (response.statusCode == 200) {
        log('datos obtenidos:  ${response.body}');

        final List<Refugio> refugios = _refugio.entries.map((entry) {
          final id = entry.key;
          final value = entry.value as Map<String, dynamic>;

          return Refugio.fromJson(id, value);
        }).toList();

        return refugios;
      } else {
        throw Exception('error al caregar datos');
      }
    } catch (e) {
      throw Exception('error al caregar datos');
    }
  }
}
