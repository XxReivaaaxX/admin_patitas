import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class RefugioManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea un nuevo refugio
  Future<void> createRefugio(
    String nombre,
    String direccion,
    String idUsuario, {
    String? telefono,
    String? whatsapp,
    String? emailContacto,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('refugios').add({
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono ?? '',
        'whatsapp': whatsapp ?? '',
        'email_contacto': emailContacto ?? '',
        'id_usuario': idUsuario,
        'created_at': FieldValue.serverTimestamp(),
        'colaboradores': {
          idUsuario: 'admin',
        },
      });
      log('Refugio creado exitosamente: ${docRef.id}', name: 'RefugioManagement');
    } catch (e) {
      log('Error al crear refugio: $e', error: e, name: 'RefugioManagement');
      rethrow;
    }
  }

  /// Actualiza los datos de un refugio
  Future<bool> updateRefugio(
    String refugioId,
    String nombre,
    String direccion, {
    String? telefono,
    String? whatsapp,
    String? emailContacto,
  }) async {
    try {
      await _firestore.collection('refugios').doc(refugioId).update({
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono ?? '',
        'whatsapp': whatsapp ?? '',
        'email_contacto': emailContacto ?? '',
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
      await _firestore.collection('refugios').doc(refugioId).delete();
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
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
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
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'registered_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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

      DocumentReference refugioRef = _firestore
          .collection('refugios')
          .doc(refugioId);
      
      DocumentSnapshot snapshot = await refugioRef.get();

      if (!snapshot.exists) {
        return {
          'success': false,
          'message': 'No se encontró el refugio.',
        };
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      var colaboradoresRaw = data['colaboradores'];

      Map<String, dynamic> colaboradores = {};
      if (colaboradoresRaw is Map) {
         colaboradores = Map<String, dynamic>.from(colaboradoresRaw);
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

      await refugioRef.update({'colaboradores': colaboradores});

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
      DocumentReference refugioRef = _firestore
          .collection('refugios')
          .doc(refugioId);

      DocumentSnapshot snapshot = await refugioRef.get();

      if (!snapshot.exists) {
        return {
          'success': false,
          'message': 'No se encontró el refugio.',
        };
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      var colaboradoresRaw = data['colaboradores'];

      if (colaboradoresRaw == null) {
        return {
          'success': false,
          'message': 'No hay colaboradores en este refugio.',
        };
      }

      Map<String, dynamic> colaboradores = {};
      if (colaboradoresRaw is Map) {
         colaboradores = Map<String, dynamic>.from(colaboradoresRaw);
      }

      // Verificar si existe
      if (!colaboradores.containsKey(userId)) {
        return {
          'success': false,
          'message': 'Este usuario no es colaborador del refugio.',
        };
      }

      // Eliminar colaborador
      colaboradores.remove(userId);

      await refugioRef.update({'colaboradores': colaboradores});

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
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['email'] as String?;
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
      DocumentReference refugioRef = _firestore
          .collection('refugios')
          .doc(refugioId);
      
      DocumentSnapshot snapshot = await refugioRef.get();

      if (!snapshot.exists) {
        return [];
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      var colaboradoresRaw = data['colaboradores'];
      
      if (colaboradoresRaw == null || colaboradoresRaw is! Map) {
        return [];
      }

      Map<String, dynamic> colaboradoresData = Map<String, dynamic>.from(colaboradoresRaw);
      List<Map<String, dynamic>> colaboradores = [];

      for (var entry in colaboradoresData.entries) {
        String userId = entry.key;
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

  /// Obtiene los roles personalizados de un refugio
  Future<List<String>> getCustomRoles(String refugioId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('refugios').doc(refugioId).get();
      if (!snapshot.exists) return ['admin', 'colaborador', 'veterinario', 'voluntario'];
      
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('roles_disponibles')) {
        return List<String>.from(data['roles_disponibles']);
      }
      
      return ['admin', 'colaborador', 'veterinario', 'voluntario'];
    } catch (e) {
      log('Error al obtener roles: $e');
      return ['admin', 'colaborador', 'veterinario', 'voluntario'];
    }
  }

  /// Agrega un nuevo rol personalizado al refugio
  Future<bool> addCustomRole(String refugioId, String roleName) async {
    try {
      DocumentReference ref = _firestore.collection('refugios').doc(refugioId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(ref);
        List<String> roles = ['admin', 'colaborador', 'veterinario', 'voluntario'];
        
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey('roles_disponibles')) {
            roles = List<String>.from(data['roles_disponibles']);
          }
        }
        
        if (!roles.contains(roleName)) {
          roles.add(roleName);
          transaction.update(ref, {'roles_disponibles': roles});
        }
      });
      return true;
    } catch (e) {
      log('Error al agregar rol: $e');
      return false;
    }
  }

  /// Actualiza el rol de un colaborador existente
  Future<Map<String, dynamic>> updateCollaboratorRole(String refugioId, String userId, String newRole) async {
    try {
      DocumentReference ref = _firestore.collection('refugios').doc(refugioId);
      await ref.update({
        'colaboradores.$userId': newRole,
      });
      return {'success': true, 'message': 'Rol actualizado correctamente.'};
    } catch (e) {
      log('Error al actualizar rol: $e');
      return {'success': false, 'message': 'Error al actualizar rol.'};
    }
  }
}
