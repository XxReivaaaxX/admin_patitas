import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animalDetails/animal_view_mobile.dart';
import 'package:admin_patitas/screens/animalDetails/animal_view_web.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class AnimalView extends StatefulWidget {
  final Animal animal;
  const AnimalView({super.key, required this.animal});

  @override
  State<AnimalView> createState() => _AnimalViewState();
}

class _AnimalViewState extends State<AnimalView> {
  Map<String, String> infoAnimal = {};
  Animal? animal;
  String? idRefugio = "";
  Future<HistorialMedico>? historialMedico;
  List<Vacuna> vacunas = [];
  bool loadingVacunas = false;
  String id_historial = '';
  bool loading = false;
  DateTime? fechaIngreso;
  Color colorPrincipal = AppColors.primary;

  @override
  void initState() {
    super.initState();
    loading = false;
    idRefugio = PreferencesController.preferences.getString('refugio');
    animal = widget.animal;
    id_historial = widget.animal.historialMedicoId;

    if (id_historial != '') {
      historialMedico = HistorialMedicoService().getHistorialMedico(
        id_historial,
      );
    }
    fechaIngreso = DateTime.parse(widget.animal.fechaIngreso);
    loadVacunas();

    log('datos obtenidos en vista:  ${widget.animal.genero}');
    infoAnimal = {
      'Nombre': widget.animal.nombre,
      'Raza': widget.animal.raza,
      'Genero': widget.animal.genero,
      'Especie': widget.animal.especie,
      'Estado de Adopción': widget.animal.estadoAdopcion,
      'Fecha': fechaIngreso != null
          ? '${fechaIngreso!.day}/${fechaIngreso!.month}/${fechaIngreso!.year}'
          : 'sin datos',
    };
  }

  Future<void> loadVacunas() async {
    if (!mounted) return;
    setState(() => loadingVacunas = true);
    try {
      final vacunasData = await VacunaService().getVacunas(
        idRefugio!,
        widget.animal.id,
      );
      if (mounted) {
        setState(() {
          vacunas = vacunasData;
          loadingVacunas = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando vacunas: $e');
      if (mounted) {
        setState(() => loadingVacunas = false);
      }
    }
  }
  // actualiza el estado del animal después de editar su información

  void _onAnimalUpdated(Animal updatedAnimal) {
    if (!mounted) return;
    final fecha = DateTime.tryParse(updatedAnimal.fechaIngreso);
    setState(() {
      animal = updatedAnimal;
      infoAnimal = {
        'Nombre': updatedAnimal.nombre,
        'Raza': updatedAnimal.raza,
        'Genero': updatedAnimal.genero,
        'Especie': updatedAnimal.especie,
        'Estado de Adopción': updatedAnimal.estadoAdopcion,
        'Fecha': fecha != null
            ? '${fecha.day}/${fecha.month}/${fecha.year}'
            : 'sin datos',
      };
    });
  }

  // actualiza el historial médico después de crearlo o editarlo
  void _onHistorialCreated(
    String newIdHistorial,
    Future<HistorialMedico> futureHistorial,
  ) {
    if (!mounted) return;
    setState(() {
      id_historial = newIdHistorial;
      historialMedico = futureHistorial;
    });
  }

  Future<void> getHistorial(String idHistorial) async {
    setState(() {
      loading = true;
      log('datos obtenidos del historial medico: }');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundLight,
        title: TextForm(
          aling: TextAlign.center,
          texto: infoAnimal['Nombre'] ?? 'Detalles del Animal',
          size: 24,
          color: colorPrincipal,
          lines: 1,
          negrita: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorPrincipal),
            onPressed: () => Navigator.pop(context, id_historial),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return AnimalViewMobile(
              animal: animal!,
              infoAnimal: infoAnimal,
              idRefugio: idRefugio,
              idHistorial: id_historial,
              historialMedico: historialMedico,
              vacunas: vacunas,
              loadingVacunas: loadingVacunas,
              loadVacunas: loadVacunas,
              onHistorialCreated: _onHistorialCreated,
              onAnimalUpdated: _onAnimalUpdated,
            );
          } else {
            return AnimalViewWeb(
              animal: animal!,
              infoAnimal: infoAnimal,
              idRefugio: idRefugio,
              historialMedico: historialMedico,
              vacunas: vacunas,
              loadingVacunas: loadingVacunas,
              constraints: constraints,
              loadVacunas: loadVacunas,
              onAnimalUpdated: _onAnimalUpdated,
            );
          }
        },
      ),
    );
  }
}
