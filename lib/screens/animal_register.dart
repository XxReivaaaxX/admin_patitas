import 'dart:convert';

import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnimalRegister extends StatefulWidget {
  final String? id_refugio;
  const AnimalRegister({super.key, required this.id_refugio});

  @override
  State<AnimalRegister> createState() => _AnimalRegisterState();
}

class _AnimalRegisterState extends State<AnimalRegister> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombre = TextEditingController();
  TextEditingController _estadoSalud = TextEditingController();
  TextEditingController _raza = TextEditingController();
  String? _especie;
  String? _sexo;
  DateTime? _fechaIngreso;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void RegistrarAnimal() async {
    const url = 'http://localhost:5000/registro-animal';
    final uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_refugio': widget.id_refugio,
          'nombre': _nombre.text,
          'especie': _especie,
          'raza': _raza.text,
          'sexo': _sexo,
          'estado_salud': _estadoSalud.text,
          'fecha_ingreso': _fechaIngreso?.toIso8601String(),
        }),
      );

      print('Código de estado: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal registrado exitosamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
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

        title: LogoBar(
          sizeImg: 32,
          colorIzq: colorPrincipal,
          colorDer: Colors.black,
          sizeText: 20,
        ),
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
                TextForm(
                  lines: 2,
                  texto: 'REGISTRO DE ANIMAL',
                  color: colorPrincipal,
                  size: 30,
                  aling: TextAlign.center,
                  negrita: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                Formulario(
                  controller: _nombre,
                  text: 'Nombre',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      child: ItemFormSelection(
                        onChanged: (value) => _especie = value,
                        validator: (value) =>
                            value == null ? 'Seleccione una especie' : null,
                        items: ['Perro', 'Gato', 'Otro'],
                        text: 'Especie',
                      ),
                    ),
                    Expanded(
                      child: ItemFormSelection(
                        onChanged: (value) => _sexo = value,
                        validator: (value) =>
                            value == null ? 'Seleccione el Sexo' : null,
                        items: ['Macho', 'Hembra'],
                        text: 'Sexo',
                      ),
                    ),
                  ],
                ),

                Formulario(
                  controller: _estadoSalud,
                  text: 'Estado de salud',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _raza,
                  text: 'Raza',
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
                        _fechaIngreso = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    _fechaIngreso == null
                        ? 'Seleccionar fecha de ingreso'
                        : 'Fecha: ${_fechaIngreso!.toLocal()}'.split(' ')[0],
                  ),
                ),
                const SizedBox(height: 24),
                BotonLogin(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      RegistrarAnimal();
                    }
                  },
                  texto: 'Registrar Animal',
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
