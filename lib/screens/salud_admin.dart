import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/screens/animal_view.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:flutter/material.dart';

class SaludAdmin extends StatefulWidget {
  final String? id_refugio;
  const SaludAdmin({super.key, required this.id_refugio});

  @override
  State<SaludAdmin> createState() => _SaludAdminState();
}

class _SaludAdminState extends State<SaludAdmin> {
  String _selectedValue = '2'; // Iniciar con Enfermedades
  String title = 'Enfermedades';
  Map<String, String> options = {'2': 'Enfermedades'};

  Future<List<Map<String, dynamic>>> _getAnimalsWithDiseases() async {
    try {
      // Obtener todos los animales del refugio
      final animals = await AnimalsService().getAnimals(widget.id_refugio!);
      List<Map<String, dynamic>> animalsWithDiseases = [];

      // Palabras clave que indican que no hay enfermedad real
      final excludeKeywords = [
        'ninguna',
        'ninguno',
        'sin datos',
        'sin enfermedad',
        'sin enfermedades',
        'vacio',
        'vacío',
        'n/a',
        'na',
        'no aplica',
        'no tiene',
        'sano',
        'saludable',
        '-',
      ];

      // Para cada animal, verificar si tiene historial médico con enfermedades
      for (var animal in animals) {
        if (animal.historialMedicoId.isNotEmpty) {
          try {
            final historial = await HistorialMedicoService().getHistorialMedico(
              animal.historialMedicoId,
            );

            // Limpiar y normalizar el texto de enfermedades
            String enfermedades = historial.enfermedades.trim().toLowerCase();

            // Verificar si tiene enfermedades registradas y no es un valor "vacío"
            if (enfermedades.isNotEmpty) {
              // Verificar que no contenga ninguna palabra clave de exclusión
              bool shouldExclude = false;
              for (var keyword in excludeKeywords) {
                if (enfermedades == keyword || enfermedades.contains(keyword)) {
                  shouldExclude = true;
                  break;
                }
              }

              // Solo agregar si no debe ser excluido
              if (!shouldExclude) {
                animalsWithDiseases.add({
                  'animal': animal,
                  'historial': historial,
                });
              }
            }
          } catch (e) {
            print('Error obteniendo historial de ${animal.nombre}: $e');
          }
        }
      }

      return animalsWithDiseases;
    } catch (e) {
      print('Error obteniendo animales con enfermedades: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
        title: Text(
          title.isEmpty ? 'Salud del Animal' : title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
      ),
      body: switch (_selectedValue) {
        '2' => FutureBuilder<List<Map<String, dynamic>>>(
          future: _getAnimalsWithDiseases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final animalsWithDiseases = snapshot.data ?? [];

            if (animalsWithDiseases.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay animales con enfermedades registradas',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: animalsWithDiseases.length,
              itemBuilder: (context, index) {
                final data = animalsWithDiseases[index];
                final Animal animal = data['animal'];
                final HistorialMedico historial = data['historial'];

                return InkWell(
                  onTap: () {
                    // Navegar a la vista del animal para ver su historial médico
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalView(animal: animal),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Imagen del animal
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: animal.imageUrl.isNotEmpty
                                      ? (animal.imageUrl.startsWith(
                                              'data:image',
                                            )
                                            ? Image.memory(
                                                Uri.parse(
                                                  animal.imageUrl,
                                                ).data!.contentAsBytes(),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.pets,
                                                        color: Colors.grey[400],
                                                      );
                                                    },
                                              )
                                            : Image.network(
                                                animal.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.pets,
                                                        color: Colors.grey[400],
                                                      );
                                                    },
                                              ))
                                      : Icon(
                                          Icons.pets,
                                          color: Colors.grey[400],
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Información del animal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      animal.nombre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${animal.especie} • ${animal.raza}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Icono de flecha para indicar que es clickeable
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          // Enfermedades
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 20,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Enfermedades:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      historial.enfermedades,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (historial.tratamiento.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.healing,
                                  size: 20,
                                  color: Colors.blue[400],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tratamiento:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        historial.tratamiento,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        _ => const Center(child: Text('Seleccione una opción')),
      },
    );
  }
}
