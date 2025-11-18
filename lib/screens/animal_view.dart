import 'dart:developer';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:flutter/material.dart';

class AnimalView extends StatefulWidget {
  final Animal animal;
  const AnimalView({super.key, required this.animal});

  @override
  State<AnimalView> createState() => _AnimalViewState();
}

class _AnimalViewState extends State<AnimalView> {
  Map<String, String> infoAnimal = {};

  Widget getMovil() {
    return Container(
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              height: 200,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(14)),
                child: Image.asset(
                  'assets/img/gatos_principal.jpg',
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
            Container(
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: TabBarView(
                children: <Widget>[
                  CardInfoAnimal(datos: infoAnimal),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Text('Specifications tab'),
                  ),
                ],
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

  @override
  void initState() {
    log('datos obtenidos en vista:  ${widget.animal.genero}');
    infoAnimal = {
      'Nombre': widget.animal.nombre,
      'Raza': widget.animal.especie,
      'Genero': widget.animal.genero,
      'Especie': widget.animal.especie,
      'Fecha': widget.animal.fechaIngreso,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: LogoBar(
          sizeImg: 25,
          colorIzq: Color.fromRGBO(55, 148, 194, 1),
          colorDer: Colors.white,
          sizeText: 15,
        ),
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
    ;
  }
}
