import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/screens/vacuna_register.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/card_info_historial.dart';
import 'package:flutter/material.dart';

class AnimalViewWeb extends StatefulWidget {
  final Animal animal;
  final Map<String, String> infoAnimal;
  final String idRefugio;
  final String idHistorial;
  final Future<HistorialMedico>? historialMedico;
  final List<Vacuna> vacunas;
  final bool loadingVacunas;
  final Future<void> Function() loadVacunas;
  final void Function(Animal animal, Map<String, String> infoAnimal)
  onAnimalUpdated;
  const AnimalViewWeb({
    super.key,
    required this.infoAnimal,
    required this.animal,
    required this.idRefugio,
    required this.idHistorial,
    this.historialMedico,
    required this.vacunas,
    required this.loadingVacunas,
    required this.loadVacunas,
    required this.onAnimalUpdated,
  });

  @override
  State<AnimalViewWeb> createState() => _AnimalViewWebState();
}

class _AnimalViewWebState extends State<AnimalViewWeb> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
