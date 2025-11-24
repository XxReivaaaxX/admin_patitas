import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_patitas/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Obtiene el rol del usuario en un refugio específico
  Future<UserRole?> getUserRole(String userId, String refugioId) async {
    try {
      DatabaseReference refugioRef = _database
          .child('refugios')
          .child(refugioId);
      DataSnapshot snapshot = await refugioRef.get();

      if (!snapshot.exists) {
        log('Refugio no encontrado', name: 'RoleService');
        return null;
      }

      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

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
        'Buscando refugios en Realtime Database para UID: $userId',
        name: 'RoleService',
      );

      // Obtener todos los refugios
      DatabaseReference refugiosRef = _database.child('refugios');
      DataSnapshot snapshot = await refugiosRef.get();

      if (!snapshot.exists) {
        log('No hay refugios en la base de datos', name: 'RoleService');
        return [];
      }

      Map<dynamic, dynamic> allRefugios =
          snapshot.value as Map<dynamic, dynamic>;
      log(
        'Total de refugios en DB: ${allRefugios.length}',
        name: 'RoleService',
      );

      allRefugios.forEach((key, value) {
        Map<dynamic, dynamic> refugioData = value as Map<dynamic, dynamic>;
        String refugioId = key as String;

        log('Verificando refugio: $refugioId', name: 'RoleService');
        log(
          'id_usuario del refugio: ${refugioData['id_usuario']}',
          name: 'RoleService',
        );
        log('Comparando con userId: $userId', name: 'RoleService');

        // Verificar si es propietario (ADMIN) - PRIORIDAD
        if (refugioData['id_usuario'] == userId) {
          log('¡Usuario es ADMIN del refugio $refugioId!', name: 'RoleService');
          refugios.add({'id': refugioId, 'data': refugioData, 'role': 'admin'});
          return; // Skip checking colaboradores for this refugio
        }

        // Verificar si es colaborador
        var colaboradores = refugioData['colaboradores'];
        log('Colaboradores: $colaboradores', name: 'RoleService');

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
      });

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

      DatabaseReference refugiosRef = _database.child('refugios');
      DataSnapshot snapshot = await refugiosRef.get();

      if (!snapshot.exists) {
        log('No hay refugios en la base de datos', name: 'RoleService');
        return [];
      }

      Map<dynamic, dynamic> allRefugios =
          snapshot.value as Map<dynamic, dynamic>;

      allRefugios.forEach((key, value) {
        Map<dynamic, dynamic> refugioData = value as Map<dynamic, dynamic>;
        String refugioId = key as String;

        // Agregar el refugio a la lista
        refugios.add({
          'id': refugioId,
          'data': refugioData,
          // No asignamos rol específico ya que es una vista pública
          'role': 'public',
        });
      });

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
