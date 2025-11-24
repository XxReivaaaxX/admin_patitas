import 'dart:convert';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _raza = TextEditingController();
  String? _especie;
  String? _sexo;
  String? _estadoAdopcion;
  DateTime? _fechaIngreso;
  String? _newImageUrl; // Para almacenar la nueva imagen si se selecciona

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    getValues();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        setState(() {
          _newImageUrl = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen seleccionada correctamente')),
        );
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void updateAnimal() async {
    try {
      final Animal animal = Animal(
        nombre: _nombre.text,
        especie: _especie!,
        raza: _raza.text,
        genero: _sexo!,
        estadoSalud: '',
        fechaIngreso: _fechaIngreso?.toIso8601String() ?? '',
        id: widget.animal.id,
        historialMedicoId: widget.animal.historialMedicoId,
        estadoAdopcion: _estadoAdopcion ?? 'No Disponible',
        imageUrl:
            _newImageUrl ??
            widget.animal.imageUrl, // Usar nueva imagen o mantener la actual
      );
      await AnimalsService().updateAnimals(widget.id_refugio!, animal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal actualizado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Excepción: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
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
    // Determinar qué imagen mostrar
    String displayImageUrl = _newImageUrl ?? widget.animal.imageUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: Text(
          widget.animal.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  texto: 'Actualizar ${widget.animal.nombre}',
                  color: colorPrincipal,
                  size: 30,
                  aling: TextAlign.center,
                  negrita: FontWeight.bold,
                ),
                const SizedBox(height: 30),

                // Imagen actual del animal
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: displayImageUrl.isNotEmpty
                              ? (displayImageUrl.startsWith('data:image')
                                    ? Image.memory(
                                        Uri.parse(
                                          displayImageUrl,
                                        ).data!.contentAsBytes(),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 80,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                      )
                                    : Image.network(
                                        displayImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 80,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                      ))
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_camera),
                        label: Text(
                          _newImageUrl != null
                              ? 'Cambiar Foto Nuevamente'
                              : 'Cambiar Foto',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrincipal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

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
                const SizedBox(height: 20),

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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 20),

                ItemFormSelection(
                  initialValue: _estadoAdopcion,
                  onChanged: (value) => _estadoAdopcion = value,
                  validator: (value) =>
                      value == null ? 'Seleccione estado de adopción' : null,
                  items: ['Disponible', 'No Disponible'],
                  text: 'Estado Adopción',
                ),
                const SizedBox(height: 20),

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
                      initialDate: _fechaIngreso ?? DateTime.now(),
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
