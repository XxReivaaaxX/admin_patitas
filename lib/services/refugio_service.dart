import 'dart:developer';

import 'package:admin_patitas/models/refugio.dart';
import 'package:admin_patitas/services/role_service.dart';

class RefugioController {
  Future<List<Refugio>> getRefugios(String idUser) async {
    try {
      // Usamos el RoleService para obtener los refugios donde el usuario 
      // es administrador o colaborador.
      final refugiosData = await RoleService().getUserRefugios(idUser);
      
      final List<Refugio> refugios = refugiosData.map((item) {
        final id = item['id'] as String;
        final data = item['data'] as Map<String, dynamic>;
        return Refugio.fromJson(id, data);
      }).toList();

      log('Refugios obtenidos de Firestore: ${refugios.length}');

      return refugios;
    } catch (e) {
      log('Error al cargar datos de refugios: $e');
      throw Exception('error al cargar datos');
    }
  }
}
