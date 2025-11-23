import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class AnimalUpdate extends StatefulWidget {
  final String? id_refugio;
  final Animal animal;
  const AnimalUpdate({
    super.key,
    required this.id_refugio,
    required this.animal,
  });

  @override
  State<AnimalUpdate> createState() => _AnimalUpdateState();
}

class _AnimalUpdateState extends State<AnimalUpdate> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombre = TextEditingController();
  TextEditingController _raza = TextEditingController();
  String? _especie;
  String? _sexo;
  String? _estadoAdopcion;
  DateTime? _fechaIngreso;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getValues();
  }

  void updateAnimal() async {
    try {
      final Animal animal = Animal(
        nombre: _nombre.text,
        especie: _especie!,
        raza: _raza.text,
        genero: _sexo!,
        estadoSalud: '', // Removed from form
        fechaIngreso: _fechaIngreso?.toIso8601String() ?? '',
        id: widget.animal.id,
        historialMedicoId: widget.animal.historialMedicoId,
        estadoAdopcion: _estadoAdopcion ?? 'No Disponible',
      );
      await AnimalsService().updateAnimals(widget.id_refugio!, animal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal actualizado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Excepción de Flutter/Dart: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    }
  }

  void getValues() {
    _nombre.text = widget.animal.nombre;
    _raza.text = widget.animal.raza;
    _especie = widget.animal.especie;
    _sexo = widget.animal.genero;
    _estadoAdopcion = widget.animal.estadoAdopcion;
    _fechaIngreso = DateTime.parse(widget.animal.fechaIngreso);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text(widget.animal.nombre),
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
                  texto: 'Actualizar ' + widget.animal.nombre,
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
                        initialValue: _especie,
                        onChanged: (value) => _especie = value,
                        validator: (value) =>
                            value == null ? 'Seleccione una especie' : null,
                        items: ['Perro', 'Gato', 'Otro'],
                        text: 'Especie',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ItemFormSelection(
                        initialValue: _sexo,
                        onChanged: (value) => _sexo = value,
                        validator: (value) =>
                            value == null ? 'Seleccione el Sexo' : null,
                        items: ['Macho', 'Hembra'],
                        text: 'Sexo',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ItemFormSelection(
                  initialValue: _estadoAdopcion,
                  onChanged: (value) => _estadoAdopcion = value,
                  validator: (value) =>
                      value == null ? 'Seleccione estado de adopción' : null,
                  items: ['Disponible', 'No Disponible'],
                  text: 'Estado Adopción',
                ),
                SizedBox(height: 20),

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // color de fondo
                    foregroundColor: Colors.black, // color del texto
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
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
                        : 'Fecha: ${_fechaIngreso!.day.toString().padLeft(2, '0')}/'
                              '${_fechaIngreso!.month.toString().padLeft(2, '0')}/'
                              '${_fechaIngreso!.year}',
                  ),
                ),
                const SizedBox(height: 24),
                BotonLogin(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateAnimal();
                    }
                  },
                  texto: 'Actualizar Animal',
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
