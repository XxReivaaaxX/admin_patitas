import 'dart:developer';

import 'package:admin_patitas/models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el rol del usuario en un refugio específico
  Future<UserRole?> getUserRole(String userId, String refugioId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('refugios').doc(refugioId).get();

      if (!snapshot.exists) {
        log('Refugio no encontrado', name: 'RoleService');
        return null;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      // Verificar si es el propietario (admin)
      if (data['id_usuario'] == userId) {
        return UserRole(userId: userId, refugioId: refugioId, role: 'admin');
      }

      // Verificar si está en la lista de colaboradores
      var colaboradores = data['colaboradores'];

      if (colaboradores is Map) {
        // Map con roles
        if (colaboradores.containsKey(userId)) {
          String role = colaboradores[userId] as String;
          return UserRole(userId: userId, refugioId: refugioId, role: role);
        }
      } else if (colaboradores is List) {
        // Array de UIDs
        if (colaboradores.contains(userId)) {
          return UserRole(
            userId: userId,
            refugioId: refugioId,
            role: 'collaborator',
          );
        }
      }

      log('Usuario no tiene acceso a este refugio', name: 'RoleService');
      return null;
    } catch (e) {
      log('Error al obtener rol: $e', error: e, name: 'RoleService');
      return null;
    }
  }

  /// Obtiene todos los refugios a los que el usuario tiene acceso
  Future<List<Map<String, dynamic>>> getUserRefugios(String userId) async {
    try {
      List<Map<String, dynamic>> refugios = [];

      log(
        'Buscando refugios en Firestore para UID: $userId',
        name: 'RoleService',
      );

      // Obtener todos los refugios con timeout de 10 segundos
      QuerySnapshot snapshot = await _firestore
          .collection('refugios')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) {
        log('No hay refugios en la base de datos', name: 'RoleService');
        return [];
      }

      log(
        'Total de refugios en Firestore: ${snapshot.docs.length}',
        name: 'RoleService',
      );

      for (var doc in snapshot.docs) {
        Map<String, dynamic> refugioData = doc.data() as Map<String, dynamic>;
        String refugioId = doc.id;

        log('Verificando refugio: $refugioId', name: 'RoleService');

        // Verificar si es propietario (ADMIN) - PRIORIDAD
        if (refugioData['id_usuario'] == userId) {
          log('¡Usuario es ADMIN del refugio $refugioId!', name: 'RoleService');
          refugios.add({'id': refugioId, 'data': refugioData, 'role': 'admin'});
          continue; // Skip checking colaboradores for this refugio
        }

        // Verificar si es colaborador
        var colaboradores = refugioData['colaboradores'];

        if (colaboradores != null) {
          bool isCollaborator = false;
          String role = 'collaborator';

          if (colaboradores is Map && colaboradores.containsKey(userId)) {
            isCollaborator = true;
            role = colaboradores[userId] as String;
            log(
              'Usuario es COLABORADOR (map) con rol: $role',
              name: 'RoleService',
            );
          } else if (colaboradores is List && colaboradores.contains(userId)) {
            isCollaborator = true;
            log('Usuario es COLABORADOR (list)', name: 'RoleService');
          }

          if (isCollaborator) {
            refugios.add({'id': refugioId, 'data': refugioData, 'role': role});
          }
        }
      }

      log(
        'Total refugios encontrados para usuario: ${refugios.length}',
        name: 'RoleService',
      );
      return refugios;
    } catch (e) {
      log('Error al obtener refugios: $e', error: e, name: 'RoleService');
      return [];
    }
  }

  /// Obtiene todos los refugios registrados en el sistema (sin filtrar por usuario)
  Future<List<Map<String, dynamic>>> getAllRefugios() async {
    try {
      List<Map<String, dynamic>> refugios = [];

      log('Obteniendo todos los refugios del sistema', name: 'RoleService');

      QuerySnapshot snapshot = await _firestore
          .collection('refugios')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) {
        log('No hay refugios en la base de datos', name: 'RoleService');
        return [];
      }

      for (var doc in snapshot.docs) {
        Map<String, dynamic> refugioData = doc.data() as Map<String, dynamic>;
        String refugioId = doc.id;

        // Agregar el refugio a la lista
        refugios.add({
          'id': refugioId,
          'data': refugioData,
          // No asignamos rol específico ya que es una vista pública
          'role': 'public',
        });
      }

      log(
        'Total refugios encontrados en el sistema: ${refugios.length}',
        name: 'RoleService',
      );
      return refugios;
    } catch (e) {
      log(
        'Error al obtener todos los refugios: $e',
        error: e,
        name: 'RoleService',
      );
      return [];
    }
  }

  /// Guarda el rol actual en SharedPreferences
  Future<void> saveCurrentRole(UserRole userRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_role', userRole.role);
    await prefs.setString('current_refugio', userRole.refugioId);
    log(
      'Rol guardado: ${userRole.role} en refugio ${userRole.refugioId}',
      name: 'RoleService',
    );
  }

  /// Obtiene el rol actual desde SharedPreferences
  Future<String?> getCurrentRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_role');
  }

  /// Verifica si el usuario actual es admin
  Future<bool> isCurrentUserAdmin() async {
    String? role = await getCurrentRole();
    return role == 'admin';
  }
}
