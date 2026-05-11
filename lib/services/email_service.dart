import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class EmailService {
  // Credenciales de EmailJS proporcionadas por el usuario
  static const String _serviceId = 'service_jx2d28m';
  static const String _templateId = 'template_4k36mxv';
  static const String _publicKey = '9xG-uxKQNFNpDX97v';

  static const String _endpoint = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Envía un correo electrónico de aprobación de adopción usando EmailJS.
  static Future<bool> sendAprobacionEmail({
    required String userName,
    required String userEmail,
    required String refugioNombre,
    required String animalName,
  }) async {
    try {
      final url = Uri.parse(_endpoint);
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'user_name': userName,
            'user_email': userEmail,
            'refugio_nombre': refugioNombre,
            'animal_name': animalName,
          },
        }),
      );

      if (response.statusCode == 200) {
        log('Correo enviado exitosamente con EmailJS.', name: 'EmailService');
        return true;
      } else {
        log(
          'Error al enviar correo con EmailJS. Código: ${response.statusCode}, Body: ${response.body}',
          name: 'EmailService',
        );
        return false;
      }
    } catch (e) {
      log('Excepción al enviar correo con EmailJS: $e', name: 'EmailService');
      return false;
    }
  }
}
