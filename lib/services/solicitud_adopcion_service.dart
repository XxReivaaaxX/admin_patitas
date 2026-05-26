import 'dart:async';
import 'dart:developer';
import 'package:admin_patitas/services/notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_patitas/services/email_service.dart';

class SolicitudAdopcionService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Encoda el correo para usarlo como clave en Firebase
  /// (Firebase no permite ".", "#", "$", "[", "]" en las claves)
  String _encodeEmail(String email) {
    return email
        .replaceAll('.', '_dot_')
        .replaceAll('@', '_at_')
        .replaceAll('#', '_hash_')
        .replaceAll('\$', '_dollar_')
        .replaceAll('[', '_lb_')
        .replaceAll(']', '_rb_');
  }

  /// Verifica si ya existe una solicitud para este correo+animal+refugio
  Future<bool> yaEnvioSolicitud({
    required String refugioId,
    required String animalId,
    required String correo,
  }) async {
    try {
      final key = _encodeEmail(correo);
      final snapshot = await _database
          .child('solicitudes_adopcion')
          .child(refugioId)
          .child(animalId)
          .child(key)
          .get();
      return snapshot.exists;
    } catch (e) {
      log(
        'Error verificando solicitud duplicada: $e',
        name: 'SolicitudService',
      );
      return false;
    }
  }

  /// Envía una nueva solicitud de adopción
  Future<void> enviarSolicitud({
    required String refugioId,
    required String refugioNombre,
    required String animalId,
    required String animalNombre,
    required String nombre,
    required String correo,
    required String telefono,
    required bool experienciaPrevia,
    required String tipoVivienda,
    required bool tieneNinos,
    required String edadesNinos,
    required bool otrasMascotas,
    required String horasSolo,
    required bool puedeCostearVet,
  }) async {
    try {
      final key = _encodeEmail(correo);
      final ref = _database
          .child('solicitudes_adopcion')
          .child(refugioId)
          .child(animalId)
          .child(key);

      await ref.set({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'animalId': animalId,
        'animalNombre': animalNombre,
        'refugioId': refugioId,
        'refugioNombre': refugioNombre,
        'experienciaPrevia': experienciaPrevia,
        'tipoVivienda': tipoVivienda,
        'tieneNinos': tieneNinos,
        'edadesNinos': edadesNinos,
        'otrasMascotas': otrasMascotas,
        'horasSolo': horasSolo,
        'puedeCostearVet': puedeCostearVet,
        'fechaSolicitud': ServerValue.timestamp,
        'estado': 'pendiente',
      });
      unawaited(
        NotificationsService().sendNotificationToCollaborators(
          refugioId: refugioId,
          title: "Nueva Solicitud de adopcion para $animalNombre",
          body: "",
          type: 'solicitudAdopcion',
          targetId: ref.key!,
        ),
      );

      log(
        'Solicitud enviada correctamente para $animalNombre',
        name: 'SolicitudService',
      );
    } catch (e) {
      log('Error al enviar solicitud: $e', name: 'SolicitudService');
      rethrow;
    }
  }

  /// Actualiza el estado de una solicitud (pendiente → aprobado | rechazado)
  /// Llama también a [enviarCorreoAprobacion] si el nuevo estado es "aprobado".
  Future<void> actualizarEstado({
    required String refugioId,
    required String animalId,
    required String correo,
    required String estado, // "aprobado" | "rechazado"
    // Datos del refugio para el correo de aprobación (opcionales por ahora)
    String? refugioNombre,
    String? refugioTelefono,
    String? refugioEmail,
    String? nombreAdoptante,
    String? animalNombre,
  }) async {
    try {
      final key = _encodeEmail(correo);
      await _database
          .child('solicitudes_adopcion')
          .child(refugioId)
          .child(animalId)
          .child(key)
          .update({'estado': estado, 'fechaRespuesta': ServerValue.timestamp});

      if (estado == 'aprobado') {
        String finalRefugioNombre = refugioNombre ?? 'el refugio';
        if (finalRefugioNombre == 'Refugio' ||
            finalRefugioNombre == 'el refugio' ||
            finalRefugioNombre.trim().isEmpty) {
          try {
            final snapshot = await _database
                .child('refugios')
                .child(refugioId)
                .child('nombre')
                .get();
            if (snapshot.exists && snapshot.value != null) {
              finalRefugioNombre = snapshot.value.toString();
            }
          } catch (e) {
            log('Error al obtener el nombre del refugio de la DB: $e',
                name: 'SolicitudService');
          }
        }

        await _enviarCorreoAprobacion(
          correoAdoptante: correo,
          nombreAdoptante: nombreAdoptante ?? 'Adoptante',
          animalNombre: animalNombre ?? 'la mascota',
          refugioNombre: finalRefugioNombre,
          refugioTelefono: refugioTelefono,
          refugioEmail: refugioEmail,
        );
      }

      log(
        'Estado actualizado a "$estado" para $correo',
        name: 'SolicitudService',
      );
    } catch (e) {
      log('Error al actualizar estado: $e', name: 'SolicitudService');
      rethrow;
    }
  }

  /// Envía un correo de aprobación al adoptante usando EmailJS.
  Future<void> _enviarCorreoAprobacion({
    required String correoAdoptante,
    required String nombreAdoptante,
    required String animalNombre,
    required String refugioNombre,
    String? refugioTelefono,
    String? refugioEmail,
  }) async {
    final enviado = await EmailService.sendAprobacionEmail(
      userName: nombreAdoptante,
      userEmail: correoAdoptante,
      refugioNombre: refugioNombre,
      animalName: animalNombre,
    );

    if (enviado) {
      log(
        'Notificación de aprobación enviada a $correoAdoptante',
        name: 'SolicitudService',
      );
    } else {
      log(
        'No se pudo enviar la notificación a $correoAdoptante',
        name: 'SolicitudService',
      );
    }
  }

  /// Obtiene todas las solicitudes de un refugio (para el panel futuro del refugio)
  Future<List<Map<String, dynamic>>> getSolicitudesByRefugio(
    String refugioId,
  ) async {
    try {
      final snapshot = await _database
          .child('solicitudes_adopcion')
          .child(refugioId)
          .get();

      if (!snapshot.exists) return [];

      final animalesMap = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> solicitudes = [];

      animalesMap.forEach((animalId, solicitudesAnimal) {
        if (solicitudesAnimal is Map) {
          solicitudesAnimal.forEach((correoKey, solicitudData) {
            if (solicitudData is Map) {
              solicitudes.add({
                'animalId': animalId,
                'correoKey': correoKey,
                ...Map<String, dynamic>.from(solicitudData),
              });
            }
          });
        }
      });

      return solicitudes;
    } catch (e) {
      log(
        'Error al obtener solicitudes del refugio: $e',
        name: 'SolicitudService',
      );
      return [];
    }
  }

  /// Obtiene todas las solicitudes de un animal específico (para el panel futuro)
  Future<List<Map<String, dynamic>>> getSolicitudesByAnimal(
    String refugioId,
    String animalId,
  ) async {
    try {
      final snapshot = await _database
          .child('solicitudes_adopcion')
          .child(refugioId)
          .child(animalId)
          .get();

      if (!snapshot.exists) return [];

      final solicitudesMap = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> solicitudes = [];

      solicitudesMap.forEach((correoKey, solicitudData) {
        if (solicitudData is Map) {
          solicitudes.add({
            'correoKey': correoKey,
            ...Map<String, dynamic>.from(solicitudData),
          });
        }
      });

      return solicitudes;
    } catch (e) {
      log(
        'Error al obtener solicitudes del animal: $e',
        name: 'SolicitudService',
      );
      return [];
    }
  }
}
