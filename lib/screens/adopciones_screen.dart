import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdopcionesScreen extends StatefulWidget {
  const AdopcionesScreen({super.key});

  @override
  State<AdopcionesScreen> createState() => _AdopcionesScreenState();
}

class _AdopcionesScreenState extends State<AdopcionesScreen> {
  List<Map<String, dynamic>> _availableAnimals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableAnimals();
  }

  Future<void> _loadAvailableAnimals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Obtener todos los refugios del usuario
      List<Map<String, dynamic>> refugios = await RoleService().getUserRefugios(
        user.uid,
      );

      List<Map<String, dynamic>> allAnimals = [];

      // 2. Iterar sobre cada refugio y obtener sus animales
      for (var refugio in refugios) {
        String refugioId = refugio['id'];
        String refugioNombre =
            refugio['data']['nombre'] ?? 'Refugio sin nombre';

        List<Animal> animals = await AnimalsService().getAnimals(refugioId);

        // 3. Filtrar por estado de adopción
        for (var animal in animals) {
          if (animal.estadoAdopcion == 'Disponible') {
            allAnimals.add({
              'animal': animal,
              'refugioNombre': refugioNombre,
              'refugioId': refugioId,
            });
          }
        }
      }

      setState(() {
        _availableAnimals = allAnimals;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando adopciones: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Adopciones Disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _availableAnimals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay animales disponibles para adopción',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableAnimals.length,
              itemBuilder: (context, index) {
                Animal animal = _availableAnimals[index]['animal'];
                String refugioNombre =
                    _availableAnimals[index]['refugioNombre'];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Imagen (Placeholder)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(
                              animal.especie == 'Gato'
                                  ? Icons
                                        .pets // Placeholder for cat
                                  : Icons.pets, // Placeholder for dog
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Información
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
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.home_work,
                                    size: 14,
                                    color: const Color.fromRGBO(
                                      55,
                                      148,
                                      194,
                                      1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    refugioNombre,
                                    style: const TextStyle(
                                      color: Color.fromRGBO(55, 148, 194, 1),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Chip de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                            ),
                          ),
                          child: const Text(
                            'Disponible',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
