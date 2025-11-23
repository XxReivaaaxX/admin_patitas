import 'dart:developer';

import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/screens/animal_register.dart';
import 'package:admin_patitas/screens/animal_view.dart';
import 'package:admin_patitas/widgets/item_animal.dart';
import 'package:flutter/material.dart';

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
    log(
      'datos obtenidos en vista:  ${AnimalsService().getAnimals(widget.refugio!)}',
    );
    //obtener lista de animales del refugio
    _futureAnimals = AnimalsService().getAnimals(widget.refugio!);

    log('refugio obtenido en vista de animales:  ${widget.refugio!}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        //recorrer lista obtenida
        child: FutureBuilder<List<Animal>>(
          future: _futureAnimals,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ItemAnimal(
                    sizeImg: 70,
                    nombre: snapshot.data![index].nombre,
                    edad: snapshot.data![index].especie,
                    estado: snapshot.data![index].estadoSalud,
                    estadoAdopcion: snapshot.data![index].estadoAdopcion,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimalView(animal: snapshot.data![index]),
                        ),
                      );
                    },
                    onpressedEliminar: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            'Eliminar a ' + snapshot.data![index].nombre,
                          ),
                          content: const Text(
                            'Desea eliminar este animal se borraran todos sus datos',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                AnimalsService().deleteAnimals(
                                  widget.refugio!,
                                  snapshot.data![index],
                                );
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      );
                    },
                    onpressedModificar: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalUpdate(
                            id_refugio: widget.refugio,
                            animal: snapshot.data![index],
                          ),
                        ),
                      );
                      //recargar la lista cuando se cierra la ventana anterior
                      setState(() {
                        _futureAnimals = AnimalsService().getAnimals(
                          widget.refugio!,
                        );
                      });
                    },
                    onPressedAdopcion: () async {
                      Animal currentAnimal = snapshot.data![index];
                      String newStatus =
                          currentAnimal.estadoAdopcion == 'Disponible'
                          ? 'No Disponible'
                          : 'Disponible';

                      log(
                        'Cambiando estado de adopción de ${currentAnimal.nombre} a $newStatus',
                      );

                      Animal updatedAnimal = Animal(
                        id: currentAnimal.id,
                        raza: currentAnimal.raza,
                        especie: currentAnimal.especie,
                        estadoSalud: currentAnimal.estadoSalud,
                        fechaIngreso: currentAnimal.fechaIngreso,
                        historialMedicoId: currentAnimal.historialMedicoId,
                        nombre: currentAnimal.nombre,
                        genero: currentAnimal.genero,
                        estadoAdopcion: newStatus,
                      );

                      await AnimalsService().updateAnimals(
                        widget.refugio!,
                        updatedAnimal,
                      );

                      // Small delay to ensure backend processes the update
                      await Future.delayed(const Duration(milliseconds: 300));

                      setState(() {
                        _futureAnimals = AnimalsService().getAnimals(
                          widget.refugio!,
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Estado de adopción actualizado a: $newStatus',
                          ),
                        ),
                      );
                    },
                  );
                  //return Text(snapshot.data![index].nombre);
                },
              );
            } else if (snapshot.hasError) {
              return Text('No tienes animales asignados');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalRegister(idRefugio: widget.refugio!),
            ),
          );
          //recargar la lista cuando se cierra la ventana anterior
          setState(() {
            _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
          });
        },

        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
