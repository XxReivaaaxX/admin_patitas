import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/screens/vacuna_register.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/card_info_historial.dart';
import 'package:admin_patitas/widgets/custom_icon_button.dart';
import 'package:admin_patitas/widgets/vacuna_card.dart';
import 'package:flutter/material.dart';

class AnimalViewWeb extends StatelessWidget {
  final Animal animal;
  final Map<String, String> infoAnimal;
  final String? idRefugio;
  final String idHistorial;
  final Future<HistorialMedico>? historialMedico;
  final List<Vacuna> vacunas;
  final bool loadingVacunas;
  final BoxConstraints constraints;
  final Future<void> Function() loadVacunas;
  final void Function(
    String newIdHistorial,
    Future<HistorialMedico> futureHistorial,
  )
  onHistorialCreated;
  final void Function(Animal updatedAnimal) onAnimalUpdated;

  const AnimalViewWeb({
    super.key,
    required this.animal,
    required this.infoAnimal,
    required this.idRefugio,
    required this.historialMedico,
    required this.vacunas,
    required this.loadingVacunas,
    required this.constraints,
    required this.loadVacunas,
    required this.onAnimalUpdated,
    required this.onHistorialCreated,
    required this.idHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 1500 ? 180 : 70,
        vertical: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen y Datos Generales
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: animal.imageUrl.isNotEmpty
                              ? (animal.imageUrl.startsWith('data:image')
                                    ? Image.memory(
                                        Uri.parse(
                                          animal.imageUrl,
                                        ).data!.contentAsBytes(),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                      )
                                    : Image.network(
                                        animal.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                      ))
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    animal.nombre,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                CustomIconButton(
                                  icono: Icons.settings,
                                  texto: "Actualizar datos",
                                  onTap: () async {
                                    final res = await showDialog(
                                      context: context,

                                      barrierColor: AppColors.primary
                                          .withOpacity(0.3),
                                      builder: (context) => Center(
                                        child: SizedBox(
                                          width: 850,
                                          height: 600,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            elevation: 10,
                                            child: AnimalUpdate(
                                              id_refugio: idRefugio,
                                              animal: animal,
                                              isMobile: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    if (res != null) {
                                      onAnimalUpdated(res);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: CardInfoAnimal(
                                datos: infoAnimal,
                                division: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Historial médico y Vacunas
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Historial médico
                if (idHistorial == '') ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear historial médico'),
                        onPressed: () async {
                          final historialRes = await showDialog(
                            context: context,
                            barrierColor: AppColors.primary.withOpacity(0.3),
                            builder: (context) => Center(
                              child: SizedBox(
                                width: 850,
                                height: 600,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 10,
                                  child: HistorialRegister(
                                    nombre: animal.nombre,
                                    id_animal: animal.id,
                                    id_refugio: idRefugio,
                                    isMobile: false,
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (historialRes != null && historialRes != '') {
                            onHistorialCreated(
                              historialRes,
                              HistorialMedicoService().getHistorialMedico(
                                historialRes,
                              ),
                            );
                          }
                        },
                      ),
                      const Text('No hay historial médico.'),
                    ],
                  ),
                ] else ...[
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.white,
                    child: FutureBuilder<HistorialMedico>(
                      future: historialMedico,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                            child: CardInfoHistorial(
                              historialMedico: snapshot.requireData,
                              nombre: animal.nombre,
                              isMobile: false,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error de historial: ${snapshot.error}');
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],

                // Sección vacunas
                Container(
                  height: 700,

                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "Vacunas",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              CustomIconButton(
                                icono: Icons.add,
                                texto: "Nueva vacuna",
                                onTap: () async {
                                  final result = await showDialog(
                                    context: context,

                                    barrierColor: AppColors.primary.withOpacity(
                                      0.3,
                                    ),
                                    builder: (context) => Center(
                                      child: SizedBox(
                                        width: 850,
                                        height: 600,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation: 10,
                                          child: VacunaRegister(
                                            refugioId: idRefugio!,
                                            animalId: animal.id,
                                            animalNombre: animal.nombre,
                                            animalEspecie: animal.especie,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  /*
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VacunaRegister(
                                        refugioId: idRefugio!,
                                        animalId: animal.id,
                                        animalNombre: animal.nombre,
                                        animalEspecie: animal.especie,
                                      ),
                                    ),
                                  );*/
                                  if (result == true) loadVacunas();
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: loadingVacunas
                              ? const Center(child: CircularProgressIndicator())
                              : vacunas.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.vaccines,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const Text('No hay vacunas registradas'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: vacunas.length,
                                  itemBuilder: (context, index) {
                                    final vacuna = vacunas[index];
                                    return VacunaCard(
                                      vacuna: vacuna,
                                      onDelete: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text(
                                              'Confirmar eliminación',
                                            ),
                                            content: Text(
                                              '¿Eliminar "${vacuna.nombre}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await VacunaService().deleteVacuna(
                                              idRefugio!,
                                              animal.id,
                                              vacuna.id,
                                            );
                                            loadVacunas();
                                          } catch (e) {
                                            log(e.toString());
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
