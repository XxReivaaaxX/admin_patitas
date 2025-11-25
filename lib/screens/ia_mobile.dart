import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_patitas/utils/url_api.dart';

class IAHandler {
  Future<void> loadModel() async {
    print('IA lista para usar API (móvil)');
  }

  // Se envía la imagen en base64 a la API y se obtiene la predicción
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

        if (data["predicciones"] != null) {
          final predicciones = data["predicciones"] as List;
          String resultado = "Top 3 predicciones:\n";
          for (var p in predicciones) {
            resultado +=
                "- ${p["clase"]} (${(p["confianza"] * 100).toStringAsFixed(2)}%)\n";
          }
          return resultado;
        } else {
          return "Respuesta inesperada: ${response.body}";
        }
      } else {
        return 'Error en API: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error al conectar con API: $e';
    }
  }
}

// Omitir lo de abajo 

/* import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class IAHandler {
  late Interpreter _interpreter;
  late List<String> _labels;

  /// Carga el modelo y las etiquetas
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      _labels = await loadLabels();
      print('Modelo y etiquetas cargados correctamente');
    } catch (e) {
      print('Error cargando modelo IA: $e');
    }
  }

  /// Carga las etiquetas desde labels.txt
  Future<List<String>> loadLabels() async {
    final raw = await rootBundle.loadString('assets/labels.txt');
    return raw.split('\n').where((label) => label.trim().isNotEmpty).toList();
  }

  /// Detecta la clase en la imagen
  Future<String> detectar(Uint8List imageBytes) async {
    try {
      final input = preprocessImage(imageBytes);
      var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter.run(input, output);

      // Buscar índice con mayor probabilidad
      int index = 0;
      double maxProb = 0.0;
      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > maxProb) {
          maxProb = output[0][i];
          index = i;
        }
      }

      return 'Detectado: ${_labels[index]} (confianza: ${(maxProb * 100).toStringAsFixed(2)}%)';
    } catch (e) {
      return 'Error en detección IA: $e';
    }
  }

  /// Convierte la imagen en tensor normalizado [1,224,224,3]
  List<List<List<List<double>>>> preprocessImage(Uint8List imageBytes) {
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) throw Exception('No se pudo decodificar la imagen');

    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    return [
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          // Para image >= 5.x
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b];
        })
      )
    ];
  }
} */









