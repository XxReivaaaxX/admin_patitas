import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_patitas/utils/url_api.dart';
import 'package:http/http.dart' as http;

class HistorialMedicoService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<String?> createHistorialMedico(
    String id_refugio,
    String id_animal,
    HistorialMedico historialMedico,
  ) async {
    try {
      // 1. Crear el nuevo historial en el nodo 'historialMedico'
      final nuevoHistorialRef = _dbRef.child('historialMedico').push();
      final String? id_historial = nuevoHistorialRef.key;

      if (id_historial == null) return '';

      await nuevoHistorialRef.set({
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });

      // 2. Actualizar la referencia del ID en el nodo del animal (siguiendo tu lógica de Python)
      // Ruta: animales / id_refugio / id_animal
      await _dbRef.child('animales/$id_refugio/$id_animal').update({
        'historial_medico_id': id_historial,
      });

      print("Historial médico creado correctamente. ID: $id_historial");
      return id_historial;
    } catch (e) {
      log('Error al crear los datos de historial medico: $e');
      return '';
    }
  }

  Future<HistorialMedico> getHistorialMedico(String id_historial) async {
    try {
      final snapshot = await _dbRef
          .child('historialMedico/$id_historial')
          .get();

      if (snapshot.exists) {
        // Firebase devuelve la data como Map<dynamic, dynamic>
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        log('Respuesta obtenida del historial: $data');

        return HistorialMedico.fromJson(id_historial, data);
      } else {
        log('Error: No se encontró el historial con ID: $id_historial');
        throw Exception('Historial no encontrado');
      }
    } catch (e) {
      log('Error en el servicio de historial: $e');
      throw Exception('Error al cargar datos');
    }
  }

  Future<void> updateHistorialMedico(
    String id_historial,
    HistorialMedico historialMedico,
  ) async {
    try {
      // Actualizamos directamente el nodo específico
      await _dbRef.child('historialMedico/$id_historial').update({
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });

      print("Historial médico actualizado correctamente");
    } catch (e) {
      log('Error al actualizar los datos de historial medico: $e');
    }
  }
}
