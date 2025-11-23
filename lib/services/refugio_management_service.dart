import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';

class RefugioManagementService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Actualiza los datos de un refugio
  Future<bool> updateRefugio(
    String refugioId,
    String nombre,
    String direccion,
  ) async {
    try {
      await _database.child('refugios').child(refugioId).update({
        'nombre': nombre,
        'direccion': direccion,
      });
      log('Refugio actualizado exitosamente', name: 'RefugioManagement');
      return true;
    } catch (e) {
      log(
        'Error al actualizar refugio: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return false;
    }
  }

  /// Elimina un refugio
  Future<bool> deleteRefugio(String refugioId) async {
    try {
      await _database.child('refugios').child(refugioId).remove();
      log('Refugio eliminado exitosamente', name: 'RefugioManagement');
      return true;
    } catch (e) {
      log('Error al eliminar refugio: $e', error: e, name: 'RefugioManagement');
      return false;
    }
  }

  /// Busca el UID de un usuario por su email en la base de datos de usuarios
  Future<String?> _findUserByEmail(String email) async {
    try {
      // Buscar en el nodo 'users' donde guardamos el mapeo email -> uid
      DatabaseReference usersRef = _database.child('users');
      DataSnapshot snapshot = await usersRef.get();

      if (!snapshot.exists) {
        return null;
      }

      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

      // Buscar el UID que corresponde al email
      for (var entry in users.entries) {
        String uid = entry.key;
        var userData = entry.value;

        if (userData is Map && userData['email'] == email) {
          return uid;
        }
      }

      return null;
    } catch (e) {
      log(
        'Error al buscar usuario por email: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return null;
    }
  }

  /// Registra un usuario en el índice de usuarios (debe llamarse al registrarse)
  Future<void> registerUserEmail(String uid, String email) async {
    try {
      await _database.child('users').child(uid).set({
        'email': email,
        'registered_at': DateTime.now().toIso8601String(),
      });
      log('Usuario registrado en índice: $email', name: 'RefugioManagement');
    } catch (e) {
      log(
        'Error al registrar usuario: $e',
        error: e,
        name: 'RefugioManagement',
      );
    }
  }

  /// Agrega un colaborador por email
  Future<Map<String, dynamic>> addCollaboratorByEmail(
    String refugioId,
    String email, {
    String role = 'collaborator',
  }) async {
    try {
      log('Buscando usuario con email: $email', name: 'RefugioManagement');

      // Buscar el UID del usuario
      String? userId = await _findUserByEmail(email);

      if (userId == null) {
        return {
          'success': false,
          'message': 'No se encontró un usuario con el email: $email',
        };
      }

      DatabaseReference refugioRef = _database
          .child('refugios')
          .child(refugioId);

      // Obtener colaboradores actuales
      DataSnapshot snapshot = await refugioRef.child('colaboradores').get();

      Map<String, dynamic> colaboradores = {};
      if (snapshot.exists) {
        var data = snapshot.value;
        if (data is Map) {
          colaboradores = Map<String, dynamic>.from(data);
        }
      }

      // Verificar si ya existe
      if (colaboradores.containsKey(userId)) {
        return {
          'success': false,
          'message': 'Este usuario ya es colaborador del refugio.',
        };
      }

      // Agregar nuevo colaborador
      colaboradores[userId] = role;

      await refugioRef.child('colaboradores').set(colaboradores);

      log(
        'Colaborador agregado exitosamente: $email',
        name: 'RefugioManagement',
      );
      return {'success': true, 'message': 'Colaborador agregado exitosamente.'};
    } catch (e) {
      log(
        'Error al agregar colaborador: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return {'success': false, 'message': 'Error al agregar colaborador: $e'};
    }
  }

  /// Elimina un colaborador
  Future<Map<String, dynamic>> removeCollaborator(
    String refugioId,
    String userId,
  ) async {
    try {
      DatabaseReference refugioRef = _database
          .child('refugios')
          .child(refugioId);

      // Obtener colaboradores actuales
      DataSnapshot snapshot = await refugioRef.child('colaboradores').get();

      if (!snapshot.exists) {
        return {
          'success': false,
          'message': 'No hay colaboradores en este refugio.',
        };
      }

      Map<String, dynamic> colaboradores = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      // Verificar si existe
      if (!colaboradores.containsKey(userId)) {
        return {
          'success': false,
          'message': 'Este usuario no es colaborador del refugio.',
        };
      }

      // Eliminar colaborador
      colaboradores.remove(userId);

      await refugioRef.child('colaboradores').set(colaboradores);

      log('Colaborador eliminado exitosamente', name: 'RefugioManagement');
      return {
        'success': true,
        'message': 'Colaborador eliminado exitosamente.',
      };
    } catch (e) {
      log(
        'Error al eliminar colaborador: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return {'success': false, 'message': 'Error al eliminar colaborador: $e'};
    }
  }

  /// Obtiene el email de un usuario por su UID
  Future<String?> getUserEmail(String userId) async {
    try {
      DataSnapshot snapshot = await _database
          .child('users')
          .child(userId)
          .child('email')
          .get();

      if (snapshot.exists) {
        return snapshot.value as String;
      }

      return null;
    } catch (e) {
      log(
        'Error al obtener email del usuario: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return null;
    }
  }

  /// Obtiene la lista de colaboradores con sus datos
  Future<List<Map<String, dynamic>>> getCollaborators(String refugioId) async {
    try {
      DatabaseReference refugioRef = _database
          .child('refugios')
          .child(refugioId);
      DataSnapshot snapshot = await refugioRef.child('colaboradores').get();

      if (!snapshot.exists) {
        return [];
      }

      Map<dynamic, dynamic> colaboradoresData =
          snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> colaboradores = [];

      for (var entry in colaboradoresData.entries) {
        String userId = entry.key as String;
        String role = entry.value as String;

        // Obtener el email del usuario
        String? email = await getUserEmail(userId);

        colaboradores.add({
          'userId': userId,
          'email': email ?? 'Email no disponible',
          'role': role,
        });
      }

      return colaboradores;
    } catch (e) {
      log(
        'Error al obtener colaboradores: $e',
        error: e,
        name: 'RefugioManagement',
      );
      return [];
    }
  }
}
