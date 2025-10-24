import 'package:flutter/material.dart';
import 'package:admin_patitas/screens/widgets/formulario.dart';
import 'package:admin_patitas/screens/widgets/botonlogin.dart';
import 'package:admin_patitas/screens/widgets/logo_bar.dart';
import 'package:admin_patitas/screens/widgets/text_form_register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroAnimal extends StatefulWidget {
  const RegistroAnimal({super.key});

  @override
  State<RegistroAnimal> createState() => _RegistroAnimalState();
}

class _RegistroAnimalState extends State<RegistroAnimal> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombre = TextEditingController();
  TextEditingController _estadoSalud = TextEditingController();
  String? _especie;
  String? _sexo;
  DateTime? _fechaIngreso;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  Future<void> registrarAnimal() async {
    final url = Uri.parse('http://localhost:5000/registro-animal');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': _nombre.text,
        'especie': _especie,
        'sexo': _sexo,
        'estado_salud': _estadoSalud.text,
        'fecha_ingreso': _fechaIngreso?.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado exitosamente')),
      );
      Navigator.pushNamed(context, '/principal');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el animal')),
      );
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
            margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Especie'),
                  items: ['Perro', 'Gato', 'Otro'].map((especie) {
                    return DropdownMenuItem(value: especie, child: Text(especie));
                  }).toList(),
                  onChanged: (value) => _especie = value,
                  validator: (value) => value == null ? 'Seleccione una especie' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: ['Macho', 'Hembra'].map((sexo) {
                    return DropdownMenuItem(value: sexo, child: Text(sexo));
                  }).toList(),
                  onChanged: (value) => _sexo = value,
                  validator: (value) => value == null ? 'Seleccione el sexo' : null,
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
                  child: Text(_fechaIngreso == null
                      ? 'Seleccionar fecha de ingreso'
                      : 'Fecha: ${_fechaIngreso!.toLocal()}'.split(' ')[0]),
                ),
                const SizedBox(height: 24),
                BotonLogin(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registrarAnimal();
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
