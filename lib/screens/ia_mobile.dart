import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class IAHandler {
  late Interpreter interpreter;
  late List<String> labels;
  late int numClasses;
  bool _isModelLoaded = false;

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

  Future<String> detectar(Uint8List bytes) async {
    if (!_isModelLoaded) throw Exception('Modelo no cargado');

    final imgDecoded = img.decodeImage(bytes);
    if (imgDecoded == null) throw Exception('No se pudo decodificar la imagen');

    final resized = img.copyResize(imgDecoded, width: 224, height: 224);

    final input = List.generate(224, (y) =>
      List.generate(224, (x) =>
        [resized.getPixel(x, y).r / 255.0,
         resized.getPixel(x, y).g / 255.0,
         resized.getPixel(x, y).b / 255.0]));

    final inputTensor = [input];
    var output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

    interpreter.run(inputTensor, output);

    final index = _argMax(output[0]);
    return labels[index];
  }

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




