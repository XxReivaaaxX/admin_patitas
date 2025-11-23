import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'animal_detectar.dart';

class AnimalDetectorMobile implements AnimalDetector {
  Interpreter? _interpreter;

  AnimalDetectorMobile() {
    _cargarModelo();
  }

  Future<void> _cargarModelo() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  @override
  Future<Map<String, String>> detectar(File imagen) async {
    var input = _preprocessImage(imagen);
    var output = List.filled(1 * 120, 0.0).reshape([1, 120]);
    _interpreter!.run(input, output);

    int index = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    String especie = index < 60 ? 'Perro' : 'Gato';
    String raza = _getLabel(index);

    return {'especie': especie, 'raza': raza};
  }

  Float32List _preprocessImage(File imageFile) {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final resized = img.copyResize(image, width: 224, height: 224);
    var buffer = Float32List(224 * 224 * 3);
    int index = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[index++] = pixel.r / 255.0;
        buffer[index++] = pixel.g / 255.0;
        buffer[index++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  String _getLabel(int index) {
    List<String> labels = [
      'Labrador', 'Bulldog', 'Pastor Alemán', 'Gato Persa', 'Gato Siamés', 'Otro'
    ];
    return labels[index < labels.length ? index : labels.length - 1];
  }
}

/// Factory para App
AnimalDetector createAnimalDetector() => AnimalDetectorMobile();


