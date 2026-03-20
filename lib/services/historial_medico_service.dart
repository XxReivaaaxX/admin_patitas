import 'dart:developer';

import 'package:admin_patitas/models/historial_medico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialMedicoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createHistorialMedico(
    String idRefugio,
    String idAnimal,
    HistorialMedico historialMedico,
  ) async {
    try {
      final docRef = await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .doc(idAnimal)
          .collection('historial_medico')
          .add({
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });
 
      // Update the animal document with the new historialMedicoId
      await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .doc(idAnimal)
          .update({'historial_medico_id': docRef.id});

      log("historial medico creado correctamente en Firestore");
    } catch (e) {
      log('error al crear los datos de historial medico $e');
    }
  }

  Future<HistorialMedico> getHistorialMedico(
    String idRefugio,
    String idAnimal,
    String idHistorial,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .doc(idAnimal)
          .collection('historial_medico')
          .doc(idHistorial)
          .get();
 
      if (snapshot.exists && snapshot.data() != null) {
        return HistorialMedico.fromJson(snapshot.id, snapshot.data()!);
      } else {
        throw Exception('Historial no encontrado');
      }
    } catch (e) {
      log('error en el servicio de historial $e');
      throw Exception('error al cargar datos');
    }
  }

  Future<void> updateHistorialMedico(
    String idRefugio,
    String idAnimal,
    String idHistorial,
    HistorialMedico historialMedico,
  ) async {
    try {
      await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .doc(idAnimal)
          .collection('historial_medico')
          .doc(idHistorial)
          .update({
        'castrado': historialMedico.castrado,
        'fecha_revision': historialMedico.fechaRevision,
        'peso': historialMedico.peso,
        'enfermedades': historialMedico.enfermedades,
        'tratamiento': historialMedico.tratamiento,
      });

      log("historial medico actualizado correctamente en Firestore");
    } catch (e) {
      log('error al actualizar los datos de historial medico $e');
    }
  }

  Future<List<HistorialMedico>> getAllHistoriales(
    String idRefugio,
    String idAnimal,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('refugios')
          .doc(idRefugio)
          .collection('animales')
          .doc(idAnimal)
          .collection('historial_medico')
          .orderBy('fecha_revision', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HistorialMedico.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      log('error al obtener todos los historiales: $e');
      return [];
    }
  }
}
