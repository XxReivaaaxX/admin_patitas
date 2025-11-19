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

class HistorialRegister extends StatefulWidget {
  final String? id_animal, id_refugio, nombre;
  const HistorialRegister({
    super.key,

    required this.nombre,
    required this.id_animal,
    required this.id_refugio,
  });

  @override
  State<HistorialRegister> createState() => _HistorialRegisterState();
}

class _HistorialRegisterState extends State<HistorialRegister> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _tratamiento = TextEditingController();
  TextEditingController _peso = TextEditingController();
  TextEditingController _enfermedades = TextEditingController();
  String? _castrado;
  DateTime? _fechaRevision;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void registerHistorial() async {
    try {
      final HistorialMedico historialMedico = HistorialMedico(
        id: '',
        peso: _peso.text,
        castrado: _castrado!,
        enfermedades: _enfermedades.text,
        fechaRevision: _fechaRevision?.toIso8601String() ?? '',
        tratamiento: _tratamiento.text,
      );
      await HistorialMedicoService().createHistorialMedico(
        widget.id_refugio!,
        widget.id_animal!,
        historialMedico,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial creado exitosamente')),
      );
      Navigator.pop(context, historialMedico);
    } catch (e) {
      print('Excepción de Flutter/Dart: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    }
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
                      registerHistorial();
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
