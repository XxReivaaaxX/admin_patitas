import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/card_info_historial.dart';
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
  String? id_refugio = "";
  late Future<HistorialMedico> historialMedico;
  bool loading = false;
  DateTime? fechaIngreso;
  Color colorPrincipal = Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    loading = false;
    id_refugio = PreferencesController.preferences.getString('refugio');

    if (widget.animal.historialMedicoId != '') {
      historialMedico = HistorialMedicoService().getHistorialMedico(
        widget.animal.historialMedicoId,
      );
      //getHistorial(widget.animal.historialMedicoId);
    }
    fechaIngreso = DateTime.parse(widget.animal.fechaIngreso);

    log('datos obtenidos en vista:  ${widget.animal.genero}');
    infoAnimal = {
      'Nombre': widget.animal.nombre,
      'Raza': widget.animal.raza,
      'Genero': widget.animal.genero,
      'Especie': widget.animal.especie,
      'Fecha': fechaIngreso != null
          ? '${fechaIngreso!.day}/${fechaIngreso!.month}/${fechaIngreso!.year}'
          : 'sin datos',
    };
  }

  Widget getMovil() {
    return Container(
      color: Colors.grey[100],
      child: DefaultTabController(
        length: 2,
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
                  Tab(text: 'Historial medico'),
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
                    Column(
                      children: [
                        Container(
                          height: 50,
                          child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.greenAccent,
                            ),
                            onPressed: () async {},
                          ),
                        ),
                        Expanded(child: CardInfoAnimal(datos: infoAnimal)),
                      ],
                    ),

                    if (widget.animal.historialMedicoId == '') ...[
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
                                      id_refugio: id_refugio,
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
                          Center(
                            child: Text(
                              'No hay historial medico selecciona + para crear uno',
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
    return Center(child: Text("falta version web"));
  }

  Future<void> getHistorial(String id_historial) async {
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
      // mostrar la pagina principal segun el tamaño de la pantalla
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return getMovil();
          } else {
            return getWeb();
          }
        },
      ),
    );
  }
}
