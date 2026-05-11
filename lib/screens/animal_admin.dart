import 'dart:developer';

import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/screens/animal_register.dart';
import 'package:admin_patitas/screens/animalDetails/animal_view.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/custom_icon_button.dart';
import 'package:admin_patitas/widgets/item_animal.dart';
import 'package:admin_patitas/widgets/item_animal_colum.dart';
import 'package:admin_patitas/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AnimalAdmin extends StatefulWidget {
  final String? refugio;
  const AnimalAdmin({super.key, required this.refugio});

  @override
  State<AnimalAdmin> createState() => _AnimalAdminState();
}

class _AnimalAdminState extends State<AnimalAdmin> {
  late Future<List<Animal>> _futureAnimals;

  // varibles para filtros
  String _searchQuery = '';
  String? _filtroEspecie;
  String? _filtroEstadoSalud;
  String? _filtroEstadoAdopcion;
  String? _filtroGenero;

  /// Dispara una nueva consulta al servicio con los criterios actuales.
  void _reloadAnimals() {
    setState(() {
      _futureAnimals = AnimalsService().filterAnimals(
        widget.refugio!,
        searchQuery: _searchQuery,
        especie: _filtroEspecie,
        estadoSalud: _filtroEstadoSalud,
        estadoAdopcion: _filtroEstadoAdopcion,
        genero: _filtroGenero,
      );
    });
  }

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
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _reloadAnimals();
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar animal...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Botón filtro
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // tu lógica de filtro
                  },
                  icon: Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(width: 10),

              // Botón agregar
              if (MediaQuery.of(context).size.width >= 700)
                CustomIconButton(
                  icono: Icons.add,
                  texto: "Nuevo Animal",
                  onTap: () async {
                    if (MediaQuery.of(context).size.width >= 1000) {
                      await showDialog(
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
                              child: AnimalRegister(idRefugio: widget.refugio!),
                            ),
                          ),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimalRegister(idRefugio: widget.refugio!),
                        ),
                      );
                    }

                    //recargar la lista cuando se cierra la ventana anterior
                    setState(() {
                      _futureAnimals = AnimalsService().getAnimals(
                        widget.refugio!,
                      );
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        //recorrer lista obtenida
        child: FutureBuilder<List<Animal>>(
          future: _futureAnimals,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ItemAnimal(
                          constraints: constraints,
                          sizeImg: 70,
                          sexo: snapshot.data![index].genero,
                          nombre: snapshot.data![index].nombre,
                          raza: snapshot.data![index].raza,
                          especie: snapshot.data![index].especie,
                          estado: snapshot.data![index].estadoSalud,
                          estadoAdopcion: snapshot.data![index].estadoAdopcion,
                          imageUrl: snapshot.data![index].imageUrl,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AnimalView(animal: snapshot.data![index]),
                              ),
                            );
                            setState(() {
                              _futureAnimals = AnimalsService().getAnimals(
                                widget.refugio!,
                              );
                            });
                          },
                          onpressedEliminar: () async {
                            final dialog = await showDialog<String>(
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
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await AnimalsService().deleteAnimals(
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
                            if (dialog == 'OK') {
                              setState(() {
                                _futureAnimals = AnimalsService().getAnimals(
                                  widget.refugio!,
                                );
                              });
                            }
                          },
                          onpressedModificar: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimalUpdate(
                                  id_refugio: widget.refugio,
                                  animal: snapshot.data![index],
                                  isMobile: true,
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
                              historialMedicoId:
                                  currentAnimal.historialMedicoId,
                              nombre: currentAnimal.nombre,
                              genero: currentAnimal.genero,
                              estadoAdopcion: newStatus,
                              imageUrl: currentAnimal.imageUrl,
                            );

                            await AnimalsService().updateAnimals(
                              widget.refugio!,
                              updatedAnimal,
                            );

                            // Small delay to ensure backend processes the update
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

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
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisExtent: 250,

                        //childAspectRatio: constraints.maxWidth < 1400 ? 1 : 1.4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ItemAnimal(
                          constraints: constraints,
                          sizeImg: 70,
                          sexo: snapshot.data![index].genero,
                          raza: snapshot.data![index].raza,
                          nombre: snapshot.data![index].nombre,
                          especie: snapshot.data![index].especie,
                          estado: snapshot.data![index].estadoSalud,
                          estadoAdopcion: snapshot.data![index].estadoAdopcion,
                          imageUrl: snapshot.data![index].imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AnimalView(animal: snapshot.data![index]),
                              ),
                            );
                          },
                          onpressedEliminar: () async {
                            final dialog = await showDialog<String>(
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
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await AnimalsService().deleteAnimals(
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
                            if (dialog == 'OK') {
                              setState(() {
                                _futureAnimals = AnimalsService().getAnimals(
                                  widget.refugio!,
                                );
                              });
                            }
                          },
                          onpressedModificar: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimalUpdate(
                                  id_refugio: widget.refugio,
                                  animal: snapshot.data![index],
                                  isMobile: true,
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
                              historialMedicoId:
                                  currentAnimal.historialMedicoId,
                              nombre: currentAnimal.nombre,
                              genero: currentAnimal.genero,
                              estadoAdopcion: newStatus,
                              imageUrl: currentAnimal.imageUrl,
                            );

                            await AnimalsService().updateAnimals(
                              widget.refugio!,
                              updatedAnimal,
                            );

                            // Small delay to ensure backend processes the update
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

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
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('No tienes animales asignados');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),

      floatingActionButton: MediaQuery.of(context).size.width < 700
          ? FloatingActionButton(
              backgroundColor: AppColors.secondary,
              shape: const CircleBorder(),

              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AnimalRegister(idRefugio: widget.refugio!),
                  ),
                );
                //recargar la lista cuando se cierra la ventana anterior
                setState(() {
                  _futureAnimals = AnimalsService().getAnimals(widget.refugio!);
                });
              },

              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
