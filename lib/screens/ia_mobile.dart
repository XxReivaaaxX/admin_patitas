import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class IAHandler {
  late Interpreter interpreter;
  late List<String> labels;
  late int numClasses;
  bool _isModelLoaded = false;

  /// Carga el modelo TFLite y las etiquetas
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('model.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      labels = labelsData.split('\n').where((e) => e.isNotEmpty).toList();
      numClasses = labels.length;
      _isModelLoaded = true;
    } catch (e) {
      throw Exception('Error al cargar modelo: $e');
    }
  }

  /// Detecta la clase más probable a partir de la imagen
  Future<String> detectar(Uint8List bytes) async {
    if (!_isModelLoaded) {
      throw Exception('Modelo no cargado');
    }

    // Decodificar imagen y redimensionar a 224x224
    final imgDecoded = img.decodeImage(bytes);
    if (imgDecoded == null) {
      throw Exception('No se pudo decodificar la imagen');
    }
    final resized = img.copyResize(imgDecoded, width: 224, height: 224);

    // Normalizar valores RGB entre 0 y 1
    final input = List.generate(224, (y) =>
      List.generate(224, (x) =>
        [resized.getPixel(x, y).r / 255.0,
         resized.getPixel(x, y).g / 255.0,
         resized.getPixel(x, y).b / 255.0]));

    final inputTensor = [input];

    // Crear salida con tamaño dinámico según numClasses
    var output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

    // Ejecutar inferencia
    interpreter.run(inputTensor, output);

    // Buscar índice con mayor probabilidad
    final index = _argMax(output[0]);
    return labels.isNotEmpty ? labels[index] : 'Clase $index';
  }

  /// Devuelve el índice del valor máximo en la lista
  int _argMax(List<double> list) {
    double maxVal = list[0];
    int maxIndex = 0;
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }
}



