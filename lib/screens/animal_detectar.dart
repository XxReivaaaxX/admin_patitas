import 'dart:io';
import 'animal_detectar_pue.dart'
    if (dart.library.io) 'animal_detectar_app.dart'
    if (dart.library.html) 'animal_detectar_web.dart';

/// Interfaz común
abstract class AnimalDetector {
  Future<Map<String, String>> detectar(File imagen);
}

/// Factory condicional
AnimalDetector getAnimalDetector() => createAnimalDetector();
