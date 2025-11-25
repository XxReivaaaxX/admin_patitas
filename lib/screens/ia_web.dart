import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_patitas/utils/url_api.dart';

class IAHandler {
  /// En Web usamos API
  Future<void> loadModel() async {
    print('IA lista para usar API');
  }

  /// Envía la imagen en base64 al API y obtiene la predicción
  Future<String> detectar(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('${UrlApi.url}detectar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': 'data:image/jpeg;base64,$base64Image'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return 'Detectado: ${data["resultado"]} (confianza: ${(data["confianza"] * 100).toStringAsFixed(2)}%)';
      } else {
        return 'Error en API: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error al conectar con API: $e';
    }
  }
}


