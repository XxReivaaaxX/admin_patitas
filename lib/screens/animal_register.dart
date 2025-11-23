import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

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
  String? _estadoAdopcion;
  DateTime? _fechaIngreso;

  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void RegistrarAnimal() async {
    try {
      final Animal animal = Animal(
        nombre: _nombre.text,
        especie: _especie!,
        raza: _raza.text,
        genero: _sexo!,
        estadoSalud: _estadoSalud.text,
        fechaIngreso: _fechaIngreso?.toIso8601String() ?? '',
        id: '',
        historialMedicoId: '',
        estadoAdopcion: _estadoAdopcion ?? 'No Disponible',
      );
      await AnimalsService().registerAnimals(widget.id_refugio!, animal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado exitosamente')),
      );
      Navigator.pop(context);
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
                    SizedBox(width: 10),
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
                SizedBox(height: 20),

                ItemFormSelection(
                  onChanged: (value) => _estadoAdopcion = value,
                  validator: (value) =>
                      value == null ? 'Seleccione estado de adopción' : null,
                  items: ['Disponible', 'No Disponible'],
                  text: 'Estado Adopción',
                ),
                SizedBox(height: 20),

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
