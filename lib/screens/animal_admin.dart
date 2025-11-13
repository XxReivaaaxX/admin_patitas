import 'dart:convert';
import 'dart:developer';

import 'package:admin_patitas/controllers/animals_controller.dart';
import 'package:admin_patitas/controllers/preferences_controller.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/screens/animal_register.dart';
import 'package:admin_patitas/screens/widgets/botonlogin.dart';
import 'package:admin_patitas/screens/widgets/formulario.dart';
import 'package:admin_patitas/screens/widgets/item_animal.dart';
import 'package:admin_patitas/screens/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
                    onTap: () {},
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
