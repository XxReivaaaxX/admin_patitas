import 'package:admin_patitas/models/notifications.dart';
import 'package:admin_patitas/models/notifications_show.dart';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_patitas/services/refugio_management_service.dart';

class NotificationsService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  //crea la notificacion base
  Future<String?> sendNotification({
    required String title,
    required String body,
    required String refugioId,
  }) async {
    try {
      final notifRef = _db.child('notifications').push();

      await notifRef.set({
        'title': title,
        'body': body,
        'refugioId': refugioId,
        'date': DateTime.now().toIso8601String(),
      });

      return notifRef.key;
    } catch (e) {
      log('Error al enviar notificación: $e', name: 'NotificationsService');
      return null;
    }
  }

  /// Crea la notificación para cada usuario de el refugio.
  Future<String?> sendNotificationToCollaborators({
    required String refugioId,
    required String title,
    required String body,
  }) async {
    try {
      //Guarda la notificación original
      final String? notifId = await sendNotification(
        title: title,
        body: body,
        refugioId: refugioId,
      );

      if (notifId != null) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        //Obtiene los colaboradores del refugio
        final refugioService = RefugioManagementService();
        final colaboradores = await refugioService.getCollaborators(refugioId);

        //Obtiene el admin del refugio (id_usuario)
        String? adminId;
        DataSnapshot snapshot = await _db
            .child('refugios')
            .child(refugioId)
            .get();
        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          adminId = data['id_usuario'];
        }

        Map<String, dynamic> updates = {};

        // envia la notificacion a cada colaborador excluyendo al usuario activo actual
        for (var colaborador in colaboradores) {
          final userId = colaborador['userId'];
          if (userId != null && userId != currentUserId) {
            updates['user_notifications/$userId/$refugioId/$notifId'] = {
              'isRead': false,
            };
          }
        }

        // envia la notificacion al administrador cuando es creada por un colaborador
        if (adminId != null && adminId != currentUserId) {
          updates['user_notifications/$adminId/$refugioId/$notifId'] = {
            'isRead': false,
          };
        }

        if (updates.isNotEmpty) {
          await _db.update(updates);
        }

        return notifId;
      }
      return null;
    } catch (e) {
      log(
        'Error al enviar notificación a destinatarios: $e',
        name: 'NotificationsService',
      );
      return null;
    }
  }

  // obtener lista de notificaciones del usuario
  Future<List<NotificationsShow>> getNotificationsForUser(
    String userId,
    String refugioId,
  ) async {
    try {
      // Obtener los ids de notificaciones del usuario
      final userNotifsSnapshot = await _db
          .child('user_notifications')
          .child(userId)
          .child(refugioId)
          .get();

      if (!userNotifsSnapshot.exists) return [];

      final userNotifsData = userNotifsSnapshot.value as Map<dynamic, dynamic>;

      // Por cada id, obtener la notificación real
      final List<NotificationsShow> result = [];

      for (final entry in userNotifsData.entries) {
        final notifId = entry.key as String;
        final statusMap = Map<dynamic, dynamic>.from(entry.value as Map);

        final notifSnapshot = await _db
            .child('notifications')
            .child(notifId)
            .get();

        if (notifSnapshot.exists) {
          final notifData = Map<dynamic, dynamic>.from(
            notifSnapshot.value as Map,
          );
          if (notifData['refugioId'] == refugioId) {
            final notification = Notifications.fromMap(notifId, notifData);
            result.add(NotificationsShow.fromFirebase(notification, statusMap));
          }
        }
      }

      return result;
    } catch (e) {
      log(
        'Error al obtener notificaciones del usuario: $e',
        name: 'NotificationsService',
      );
      return [];
    }
  }

  //actualiza estado de lectura

  Future<void> updateReadNotificationState({
    required String userId,
    required String notifId,
    required String refugioId,
  }) async {
    try {
      await _db
          .child('user_notifications')
          .child(userId)
          .child(refugioId)
          .child(notifId)
          .update({'isRead': true});
    } catch (e) {
      log(
        'Error al marcar notificación como leída: $e',
        name: 'NotificationsService',
      );
    }
  }

  //revisa cambios de lectura en tiempo real

  Stream<int> getUnreadCountStream(String userId, String refugioId) {
    return _db
        .child('user_notifications')
        .child(userId)
        .child(refugioId)
        .onValue
        .map((event) {
          if (!event.snapshot.exists) return 0;

          final data = event.snapshot.value as Map<dynamic, dynamic>;

          int count = 0;
          data.forEach((key, value) {
            if (value['isRead'] == false) {
              count++;
            }
          });
          return count;
        });
  }
}
