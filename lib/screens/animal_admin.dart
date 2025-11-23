import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/screens/animal_register.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/animal_view.dart';
import 'package:admin_patitas/widgets/item_animal.dart';

class AnimalAdmin extends StatefulWidget {
  final String? refugio;
  const AnimalAdmin({super.key, required this.refugio});

  @override
  State<AnimalAdmin> createState() => _AnimalAdminState();
}

class _AnimalAdminState extends State<AnimalAdmin> {
  late Future<List<Animal>> _futureAnimals;

  @override
  void initState() {
    _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: FutureBuilder<List<Animal>>(
          future: _futureAnimals,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Error al cargar animales');
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay animales registrados', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnimalRegister(idRefugio: widget.refugio!)),
                      );
                      setState(() {
                        _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Animal'),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final animal = snapshot.data![index];
                return ItemAnimal(
                  sizeImg: 70,
                  nombre: animal.nombre,
                  edad: 'Especie: ${animal.especie}',
                  estado: 'Estado: ${animal.estadoSalud}',
                  estadoAdopcion: animal.estadoAdopcion,
                  imageUrl: animal.imageUrl, // ahora se pasa la imagen
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AnimalView(animal: animal)));
                  },
                  onpressedEliminar: () async {
                    final confirm = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Eliminar a ${animal.nombre}'),
                        content: const Text('¿Desea eliminar este animal? Se borrarán todos sus datos.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () async {
                              await AnimalsService().deleteAnimals(widget.refugio!, animal);
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == 'OK') {
                      setState(() {
                        _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
                      });
                    }
                  },
                  onpressedModificar: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnimalUpdate(id_refugio: widget.refugio, animal: animal)),
                    );
                    setState(() {
                      _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
                    });
                  },
                  onPressedAdopcion: () async {
                    final nuevoEstado = animal.estadoAdopcion == 'Disponible' ? 'No Disponible' : 'Disponible';
                    final actualizado = Animal(
                      id: animal.id,
                      nombre: animal.nombre,
                      especie: animal.especie,
                      raza: animal.raza,
                      genero: animal.genero,
                      estadoSalud: animal.estadoSalud,
                      fechaIngreso: animal.fechaIngreso,
                      historialMedicoId: animal.historialMedicoId,
                      estadoAdopcion: nuevoEstado,
                      imageUrl: animal.imageUrl,
                    );
                    await AnimalsService().updateAnimals(widget.refugio!, actualizado);
                    setState(() {
                      _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado a: $nuevoEstado')));
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AnimalRegister(idRefugio: widget.refugio!)));
          setState(() {
            _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

