import 'dart:developer';

import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/screens/historial_update.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class CardInfoHistorial extends StatefulWidget {
  final HistorialMedico historialMedico;
  final String nombre;
  final String idRefugio;
  final String idAnimal;
  const CardInfoHistorial({
    super.key,
    required this.historialMedico,
    required this.nombre,
    required this.idRefugio,
    required this.idAnimal,
  });

  @override
  State<CardInfoHistorial> createState() => _CardInfoHistorialState();
}

class _CardInfoHistorialState extends State<CardInfoHistorial> {
  late HistorialMedico historialMedico;
  DateTime? fechaRevision;
  @override
  void initState() {
    super.initState();
    log('fecha revision:  ${widget.historialMedico.fechaRevision}');
    if (widget.historialMedico.fechaRevision != '') {
      fechaRevision = DateTime.parse(widget.historialMedico.fechaRevision);
    }

    historialMedico = widget.historialMedico;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            icon: Icon(Icons.settings, color: AppColors.secondary),
            onPressed: () async {
              final respuesta = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistorialUpdate(
                    idRefugio: widget.idRefugio,
                    idAnimal: widget.idAnimal,
                    idHistorial: widget.historialMedico.id,
                    nombre: widget.nombre,
                    historialMedico: widget.historialMedico,
                  ),
                ),
              );
              //recargar la lista cuando se cierra la ventana anterior
              if (respuesta != null) {
                setState(() {
                  historialMedico = respuesta;
                  // Actualizar también la fecha de revisión
                  if (historialMedico.fechaRevision.isNotEmpty) {
                    try {
                      fechaRevision = DateTime.parse(
                        historialMedico.fechaRevision,
                      );
                    } catch (e) {
                      log('Error parsing updated date: $e');
                    }
                  }
                });
              }
            },
            label: const Text('Actualizar Historial'),
          ),
          CardInfoAnimal(
            datos: {
              'Fecha de Revisión': fechaRevision != null
                  ? '${fechaRevision!.day}/${fechaRevision!.month}/${fechaRevision!.year}'
                  : "sin datos",
              'Peso': historialMedico.peso,
              'Castrado': historialMedico.castrado,
            },
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: TextForm(
                    lines: 1,
                    texto: 'Enfermedades',
                    color: Colors.blue,
                    size: 15,
                    aling: TextAlign.left,
                    negrita: FontWeight.normal,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: TextForm(
                  lines: 10,
                  texto: historialMedico.enfermedades,
                  color: Colors.black,
                  size: 15,
                  aling: TextAlign.justify,
                  negrita: FontWeight.normal,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: TextForm(
                    lines: 1,
                    texto: 'Tratamiento',
                    color: Colors.blue,
                    size: 15,
                    aling: TextAlign.left,
                    negrita: FontWeight.normal,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: TextForm(
                  lines: 10,
                  texto: historialMedico.tratamiento,
                  color: Colors.black,
                  size: 15,
                  aling: TextAlign.justify,
                  negrita: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
