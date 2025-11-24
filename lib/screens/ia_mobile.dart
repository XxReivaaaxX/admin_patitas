import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class IAHandler {
  late Interpreter interpreter;
  late List<String> labels;
  late int numClasses;

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('model.tflite');
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    labels = labelsData.split('\n').where((e) => e.isNotEmpty).toList();
    numClasses = labels.length;
  }

  Future<String> detectar(Uint8List bytes) async {
    final imgDecoded = img.decodeImage(bytes);
    final resized = img.copyResize(imgDecoded!, width: 224, height: 224);

    final input = List.generate(224, (y) =>
      List.generate(224, (x) =>
        [resized.getPixel(x, y).r / 255.0,
         resized.getPixel(x, y).g / 255.0,
         resized.getPixel(x, y).b / 255.0]));
    final inputTensor = [input];

    var output = List.filled(numClasses, 0.0).reshape([1, numClasses]);
    interpreter.run(inputTensor, output);

    final index = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    return labels.isNotEmpty ? labels[index] : 'Clase $index';
  }
}


