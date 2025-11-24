import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/screens/vacuna_register.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/card_info_historial.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:admin_patitas/widgets/vacuna_card.dart';
import 'package:flutter/material.dart';

class AnimalView extends StatefulWidget {
  final Animal animal;
  const AnimalView({super.key, required this.animal});

  @override
  State<AnimalView> createState() => _AnimalViewState();
}

class _AnimalViewState extends State<AnimalView> {
  Map<String, String> infoAnimal = {};
  String? idRefugio = "";
  late Future<HistorialMedico> historialMedico;
  List<Vacuna> vacunas = [];
  bool loadingVacunas = false;
  bool loading = false;
  DateTime? fechaIngreso;
  Color colorPrincipal = Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    loading = false;
    idRefugio = PreferencesController.preferences.getString('refugio');

    if (widget.animal.historialMedicoId != '') {
      historialMedico = HistorialMedicoService().getHistorialMedico(
        widget.animal.historialMedicoId,
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

  Widget getMovil() {
    return Container(
      color: Colors.grey[100],
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(14)),
                child: Image.asset(
                  'assets/img/gatos_principal.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TabBar.secondary(
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                labelPadding: EdgeInsets.symmetric(horizontal: 40),
                indicatorPadding: EdgeInsetsGeometry.symmetric(horizontal: 40),
                tabs: const <Widget>[
                  Tab(text: 'Datos generales'),
                  Tab(text: 'Historial médico'),
                  Tab(text: 'Vacunas'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      blurStyle: BlurStyle.outer,
                      color: Colors.grey,
                      blurRadius: BorderSide.strokeAlignOutside,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: TabBarView(
                  children: <Widget>[
                    // Primera tab: Datos generales
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalUpdate(
                                      id_refugio: idRefugio,
                                      animal: widget.animal,
                                    ),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 50,
                              ),
                              child: CardInfoAnimal(datos: infoAnimal),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Segunda tab: Historial médico
                    if (widget.animal.historialMedicoId == '') ...[
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Crear historial médico'),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistorialRegister(
                                      nombre: widget.animal.nombre,
                                      id_animal: widget.animal.id,
                                      id_refugio: idRefugio,
                                    ),
                                  ),
                                );
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'No hay historial médico. Selecciona + para crear uno',
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      FutureBuilder<HistorialMedico>(
                        future: historialMedico,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: CardInfoHistorial(
                                historialMedico: snapshot.requireData,
                                nombre: widget.animal.nombre,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            log(
                              'error de historial detectado por el future builder: ${snapshot.error}',
                            );
                            return Text(
                              'error de historial detectado por el future builder: ${snapshot.error}',
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],

                    // Tercera tab: Vacunas
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.greenAccent,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VacunaRegister(
                                        refugioId: idRefugio!,
                                        animalId: widget.animal.id,
                                        animalNombre: widget.animal.nombre,
                                        animalEspecie: widget.animal.especie,
                                      ),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    loadVacunas();
                                  }
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
                                      const SizedBox(height: 16),
                                      Text(
                                        'No hay vacunas registradas',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Presiona + para agregar una vacuna',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
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
                                              '¿Eliminar vacuna "${vacuna.nombre}"?',
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
                                              widget.animal.id,
                                              vacuna.id,
                                            );
                                            if (mounted) {
                                              loadVacunas();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Vacuna eliminada',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // visualisacion para pantallas grandes
  Widget getWeb() {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: 50),

      child: ListView(
        children: [
          //datos generales
          Container(
            height: 400,
            margin: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            child: Card(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        child: Image.asset(
                          'assets/img/gatos_principal.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: TextButton.icon(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalUpdate(
                                      id_refugio: idRefugio,
                                      animal: widget.animal,
                                    ),
                                  ),
                                );
                                setState(() {});
                              },
                              label: Text('Actualizar Datos'),
                            ),
                          ),
                          Expanded(child: CardInfoAnimal(datos: infoAnimal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //historial medico
          if (widget.animal.historialMedicoId == '') ...[
            //historial vacio
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),

                    label: const Text('Crear historial medico'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistorialRegister(
                            nombre: widget.animal.nombre,
                            id_animal: widget.animal.id,
                            id_refugio: idRefugio,
                          ),
                        ),
                      );
                      //recargar la lista cuando se cierra la ventana anterior
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                Text('No hay historial medico selecciona + para crear uno'),
              ],
            ),
          ] else ...[
            //historial lleno
            Card(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 100),
              color: Colors.white,
              child: FutureBuilder<HistorialMedico>(
                future: historialMedico,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: CardInfoHistorial(
                        historialMedico: snapshot.requireData,
                        nombre: widget.animal.nombre,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    log(
                      'error de historial detectado por el future builder: ${snapshot.error}',
                    );
                    return Text(
                      'error de historial detectado por el future builder: ${snapshot.error}',
                    );
                  }

                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ],
      ),
    );
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
        backgroundColor: Colors.white,
        title: TextForm(
          aling: TextAlign.center,
          texto: widget.animal.nombre,
          size: 24,
          color: colorPrincipal,
          lines: 1,
          negrita: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorPrincipal),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return getMovil();
          } else {
            return getWeb();
          }
        },
      ),
    );
  }
}
