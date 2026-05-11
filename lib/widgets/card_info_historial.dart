import 'dart:developer';

import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/screens/historial_update.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/custom_icon_button.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class CardInfoHistorial extends StatefulWidget {
  final HistorialMedico historialMedico;
  final String nombre;
  final bool isMobile;
  const CardInfoHistorial({
    super.key,
    required this.historialMedico,
    required this.nombre,
    required this.isMobile,
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
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: !widget.isMobile
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Historial Medico",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      CustomIconButton(
                        icono: Icons.settings,
                        texto: "Actualizar datos",
                        onTap: () async {
                          final respuesta = await showDialog(
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
                                  child: HistorialUpdate(
                                    id_historial: widget.historialMedico.id,
                                    nombre: widget.nombre,
                                    historialMedico: widget.historialMedico,
                                    isMobile: widget.isMobile,
                                  ),
                                ),
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
                                  print('Error parsing updated date: $e');
                                }
                              }
                            });
                          }
                        },
                      ),
                    ],
                  )
                : Container(
                    alignment: Alignment.centerRight,
                    child: CustomIconButton(
                      icono: Icons.settings,
                      texto: "Actualizar Historial",
                      onTap: () async {
                        final respuesta = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistorialUpdate(
                              id_historial: widget.historialMedico.id,
                              nombre: widget.nombre,
                              historialMedico: widget.historialMedico,
                              isMobile: widget.isMobile,
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
                                print('Error parsing updated date: $e');
                              }
                            }
                          });
                        }
                      },
                    ),
                  ),
          ),
          SizedBox(height: 20),
          CardInfoAnimal(
            datos: {
              'Fecha de Revisión': fechaRevision != null
                  ? '${fechaRevision!.day}/${fechaRevision!.month}/${fechaRevision!.year}'
                  : "sin datos",
              'Peso': historialMedico.peso,
              'Castrado': historialMedico.castrado,
            },
            division: widget.isMobile ? 2 : 3,
          ),
          Container(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: TextForm(
                    lines: 1,
                    texto: 'Enfermedades',
                    color: AppColors.primary,
                    size: 15,
                    aling: TextAlign.left,
                    negrita: FontWeight.normal,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 150,

                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
          ),

          Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  alignment: Alignment.centerLeft,
                  child: TextForm(
                    lines: 1,
                    texto: 'Tratamiento',
                    color: AppColors.primary,
                    size: 15,
                    aling: TextAlign.left,
                    negrita: FontWeight.normal,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
          ),
        ],
      ),
    );
  }
}
