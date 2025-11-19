import 'dart:convert';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistorialUpdate extends StatefulWidget {
  final String? id_historial, nombre;
  final HistorialMedico historialMedico;
  const HistorialUpdate({
    super.key,
    required this.id_historial,
    required this.nombre,
    required this.historialMedico,
  });

  @override
  State<HistorialUpdate> createState() => _HistorialUpdateState();
}

class _HistorialUpdateState extends State<HistorialUpdate> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _tratamiento = TextEditingController();
  TextEditingController _peso = TextEditingController();
  TextEditingController _enfermedades = TextEditingController();
  String? _castrado;
  String? _sexo;
  DateTime? _fechaRevision;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getValues();
  }

  void updateHistorial() async {
    try {
      final HistorialMedico historialMedico = HistorialMedico(
        id: widget.id_historial!,
        peso: _peso.text,
        castrado: _castrado!,
        enfermedades: _enfermedades.text,
        fechaRevision: _fechaRevision?.toIso8601String() ?? '',
        tratamiento: _tratamiento.text,
      );
      await HistorialMedicoService().updateHistorialMedico(
        widget.id_historial!,
        historialMedico,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial registrado exitosamente')),
      );
      Navigator.pop(context, historialMedico);
    } catch (e) {
      print('Excepción de Flutter/Dart: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    }
  }

  void getValues() {
    _peso.text = widget.historialMedico.fechaRevision;
    _enfermedades.text = widget.historialMedico.enfermedades;
    _tratamiento.text = widget.historialMedico.tratamiento;
    _castrado = widget.historialMedico.castrado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Historial ' + widget.nombre!),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
            child: ListView(
              shrinkWrap: true,
              children: [
                Formulario(
                  controller: _peso,
                  text: ' Peso',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),

                Container(
                  child: ItemFormSelection(
                    onChanged: (value) => _castrado = value,
                    validator: (value) => value == null ? 'Castrado' : null,
                    items: ['si', 'no'],
                    text: 'Castrado',
                  ),
                ),

                Formulario(
                  controller: _enfermedades,
                  text: 'Enfermedades',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _tratamiento,
                  text: ' Tratamiento',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaRevision = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    _fechaRevision == null
                        ? 'Seleccionar fecha de ingreso'
                        : 'Fecha: ${_fechaRevision!.toLocal()}'.split(' ')[0],
                  ),
                ),
                const SizedBox(height: 24),
                BotonLogin(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateHistorial();
                    }
                  },
                  texto: 'Actualizar informacion',
                  color: Colors.white,
                  colorB: colorPrincipal,
                  size: 15,
                  negrita: FontWeight.normal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
