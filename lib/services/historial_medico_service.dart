import 'dart:developer';

import 'package:admin_patitas/models/historial_medico.dart';
import 'package:firebase_database/firebase_database.dart';

class HistorialMedicoService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<String?> createHistorialMedico(
    String idRefugio,
    String idAnimal,
    HistorialMedico historialMedico,
  ) async {
    try {
      // 1. Crear el nuevo historial en el nodo 'historialMedico'
      final nuevoHistorialRef = _dbRef.child('historialMedico').push();
      final String? idHistorial = nuevoHistorialRef.key;

      if (idHistorial == null) return '';

      await nuevoHistorialRef.set({
        'id_refugio': idRefugio,
        'id_animal': idAnimal,
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });

      // 2. Actualizar la referencia del ID en el nodo del animal (siguiendo tu lógica de Python)
      // Ruta: animales / id_refugio / id_animal
      await _dbRef.child('animales/$idRefugio/$idAnimal').update({
        'historial_medico_id': idHistorial,
      });

      log('Historial médico creado correctamente. ID: $idHistorial');
      return idHistorial;
    } catch (e) {
      log('Error al crear los datos de historial medico: $e');
      return '';
    }
  }

  Future<HistorialMedico> getHistorialMedico(String idHistorial) async {
    try {
      final snapshot = await _dbRef.child('historialMedico/$idHistorial').get();

      if (snapshot.exists) {
        // Firebase devuelve la data como Map<dynamic, dynamic>
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        log('Respuesta obtenida del historial: $data');

        return HistorialMedico.fromJson(idHistorial, data);
      } else {
        log('Error: No se encontró el historial con ID: $idHistorial');
        throw Exception('Historial no encontrado');
      }
    } catch (e) {
      log('Error en el servicio de historial: $e');
      throw Exception('Error al cargar datos');
    }
  }

  Future<void> updateHistorialMedico(
    String idHistorial,
    HistorialMedico historialMedico,
  ) async {
    try {
      // Actualizamos directamente el nodo específico
      await _dbRef.child('historialMedico/$idHistorial').update({
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });

      log('Historial médico actualizado correctamente');
    } catch (e) {
      log('Error al actualizar los datos de historial medico: $e');
    }
  }
}
