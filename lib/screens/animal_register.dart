import 'dart:typed_data';
import 'dart:convert';

import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnimalRegister extends StatefulWidget {
  final String idRefugio;
  const AnimalRegister({super.key, required this.idRefugio});

  @override
  State<AnimalRegister> createState() => _AnimalRegisterState();
}

class _AnimalRegisterState extends State<AnimalRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _raza = TextEditingController();
  String? _especie;
  String? _sexo;
  String? _estadoAdopcion;
  DateTime? _fechaIngreso;
  XFile? _imagen;
  bool _isLoading = false;

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    try {
      final img = await picker.pickImage(source: ImageSource.gallery);
      if (img != null) {
        setState(() => _imagen = img);
      }
    } catch (e) {
      print('Error seleccionando imagen: $e');
    }
  }

  /*
  Future<void> detectarAnimal(File imagen) async {
    // Falta implementar preprocessImage, reshape y getLabel
    // var input = preprocessImage(imagen);
    // var output = List.filled(1 * 120, 0).reshape([1, 120]);
    // _interpreter!.run(input, output);
    // ...
  }
  */

  Future<void> registrarAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una foto del animal'),
        ),
      );
      return;
    }

    if (_fechaIngreso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione la fecha de ingreso'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Iniciando registro de animal...');

      // 1. Convertir imagen a Base64 para guardar en Realtime Database
      print('Convirtiendo imagen a Base64...');
      final bytes = await _imagen!.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      print('Imagen convertida exitosamente');

      // 2. Guardar en Realtime Database
      print('Creando objeto Animal...');
      final Animal animal = Animal(
        nombre: _nombre.text,
        especie: _especie!,
        raza: _raza.text,
        genero: _sexo!,
        estadoSalud: '',
        fechaIngreso: _fechaIngreso?.toIso8601String() ?? '',
        id: '',
        historialMedicoId: '',
        estadoAdopcion: _estadoAdopcion ?? 'No Disponible',
        imageUrl: base64Image,
      );

      print('Guardando en Realtime Database...');
      await AnimalsService().registerAnimals(widget.idRefugio, animal);
      print('Animal registrado exitosamente');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal registrado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      print('Error al registrar animal: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Animal'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
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

              // Botón para seleccionar foto
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: _isLoading ? null : seleccionarImagen,
              ),
              if (_imagen != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: FutureBuilder<Uint8List>(
                    future: _imagen!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          height: 150,
                          fit: BoxFit.cover,
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : BotonLogin(
                      onPressed: registrarAnimal,
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
    );
  }
}
