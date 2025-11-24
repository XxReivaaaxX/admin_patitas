import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'animal_detectar.dart';

class AnimalDetectorWeb implements AnimalDetector {
  @override
  Future<Map<String, String>> detectar(File imagen) async {
    Uint8List bytes = await imagen.readAsBytes();

    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/detectar'));
    request.files.add(http.MultipartFile.fromBytes('imagen', bytes, filename: 'imagen.jpg'));

    var response = await request.send();
    if (response.statusCode == 200) {
      var data = jsonDecode(await response.stream.bytesToString());
      return {'especie': data['especie'], 'raza': data['raza']};
    } else {
      throw Exception('Error en API Web');
    }
  }
}

/// Factory para Web
AnimalDetector createAnimalDetector() => AnimalDetectorWeb();

