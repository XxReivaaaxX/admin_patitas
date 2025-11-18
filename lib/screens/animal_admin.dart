import 'dart:developer';

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
      'datos obtenidos en vista:  ${AnimalsController().getAnimals(widget.refugio!)}',
    );
    //obtener lista de animales del refugio
    _futureAnimals = AnimalsController().getAnimals(widget.refugio!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimalView(animal: snapshot.data![index]),
                        ),
                      );
                    },
                    onpressedEliminar: () {},
                    onpressedModificar: () {},
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalRegister(id_refugio: widget.refugio),
            ),
          );
          //recargar la lista cuando se cierra la ventana anterior
          setState(() {
            _futureAnimals = AnimalsController().getAnimals(widget.refugio!);
          });
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
