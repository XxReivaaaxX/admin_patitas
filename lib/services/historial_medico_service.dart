import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;

class HistorialMedicoService {
  Future<void> createHistorialMedico(
    String id_refugio,
    String id_animal,
    HistorialMedico historialMedico,
  ) async {
    try {
      final uri = Uri.parse(UrlApi.url + "registro-historial-medico");

      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_refugio': id_refugio,
          'id_animal': id_animal,
          'castrado': historialMedico.castrado,
          'fecha_revision': historialMedico.fechaRevision,
          'peso': historialMedico.peso,
          'enfermedades': historialMedico.enfermedades,
          'tratamiento': historialMedico.tratamiento,
        }),
      );

      print("historial medico creado correctamente");
    } catch (e) {
      log('error al crear los datos de historial medico $e');
    }
  }

  Future<HistorialMedico> getHistorialMedico(String id_historial) async {
    try {
      final uri = Uri.parse(UrlApi.url + "historial-medico/" + id_historial);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        log('respuesta obtenida del historial:  ${response.body}');
        final Map<String, dynamic> _historial = jsonDecode(response.body);

        final HistorialMedico historialMedico = HistorialMedico.fromJson(
          id_historial,
          _historial,
        );

        return historialMedico;
      } else {
        log('error al obtener los datos de historial');
        throw Exception('error al obtener datos del historial');
      }
    } catch (e) {
      log('error en el servicio de historial $e');
      throw Exception('error al caregar datos');
    }
  }

  Future<void> updateHistorialMedico(
    String id_historial,
    HistorialMedico historialMedico,
  ) async {
    try {
      final uri = Uri.parse(UrlApi.url + "update-historial-medico");

      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_historial': id_historial,
          'castrado': historialMedico.castrado,
          'fecha_revision': historialMedico.fechaRevision,
          'peso': historialMedico.peso,
          'enfermedades': historialMedico.enfermedades,
          'tratamiento': historialMedico.tratamiento,
        }),
      );

      print("historial medico actualizado correctamente");
    } catch (e) {
      log('error al actualizar los datos de historial medico $e');
    }
  }
}
