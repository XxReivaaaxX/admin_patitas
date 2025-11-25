import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'ia_mobile.dart' if (dart.library.html) 'ia_web.dart' as IA;

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
  bool _modeloCargado = false;

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  late IA.IAHandler ia;

  @override
  void initState() {
    super.initState();
    ia = IA.IAHandler();
    _initIA();
  }

  Future<void> _initIA() async {
    await ia.loadModel();
    setState(() => _modeloCargado = true);
  }

  Future<void> seleccionarImagen({required bool desdeCamara}) async {
    final picker = ImagePicker();
    final imgFile = await picker.pickImage(
      source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
    );
    if (imgFile != null) setState(() => _imagen = imgFile);
  }

  Future<void> descargarImagen() async {
    if (_imagen == null) return;
    setState(() => _isLoading = true);

    try {
      final bytes = await _imagen!.readAsBytes();
      final fileName =
          "${_nombre.text.isNotEmpty ? _nombre.text : 'animal'}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      if (kIsWeb) {
        // Implementación para Web si se requiere
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        _showSnack('Imagen guardada en: $filePath');
      }
    } catch (e) {
      _showSnack('Error al descargar imagen: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> registrarAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagen == null) {
      _showSnack('Por favor seleccione una foto del animal');
      return;
    }

    if (_fechaIngreso == null) {
      _showSnack('Por favor seleccione la fecha de ingreso');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await _imagen!.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final animal = Animal(
        nombre: _nombre.text,
        especie: _especie!,
        raza: _raza.text,
        genero: _sexo!,
        estadoSalud: '',
        fechaIngreso: _fechaIngreso!.toIso8601String(),
        id: '',
        historialMedicoId: '',
        estadoAdopcion: _estadoAdopcion ?? 'No Disponible',
        imageUrl: base64Image,
      );

      await AnimalsService().registerAnimals(widget.idRefugio, animal);

      if (mounted) {
        _showSnack('Animal registrado exitosamente');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Error al registrar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> detectarAnimal() async {
    if (_imagen == null) return;
    setState(() => _isLoading = true);

    try {
      final bytes = await _imagen!.readAsBytes();
      final resultado = await ia.detectar(bytes);
      _showSnack('Detectado: $resultado');
    } catch (e) {
      _showSnack('Error en IA: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Animal')),
      body: SafeArea(
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
                  const SizedBox(width: 10),
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
              const SizedBox(height: 20),
              ItemFormSelection(
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

              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar Imagen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Cámara'),
                                onTap: () {
                                  Navigator.pop(context);
                                  seleccionarImagen(desdeCamara: true);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Galería'),
                                onTap: () {
                                  Navigator.pop(context);
                                  seleccionarImagen(desdeCamara: false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
              ),

              if (_imagen != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    ClipOval(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: kIsWeb
                            ? Image.network(
                                _imagen!.path,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_imagen!.path),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.delete,
                          label: 'Eliminar',
                          color: Colors.red,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                    '¿Desea eliminar la imagen seleccionada?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              setState(() => _imagen = null);
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.change_circle,
                          label: 'Cambiar',
                          color: Colors.blue,
                          onPressed: () => seleccionarImagen(desdeCamara: false),
                        ),
                        _buildActionButton(
                          icon: Icons.download,
                          label: 'Descargar',
                          color: Colors.green,
                          onPressed: descargarImagen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!kIsWeb)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Detectar Animal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed:
                            (!_modeloCargado || _isLoading) ? null : detectarAnimal,
                      ),
                    if (!_modeloCargado)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Cargando modelo IA...',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
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
                    locale: const Locale('es', 'ES'),
                  );
                  if (pickedDate != null)
                    setState(() => _fechaIngreso = pickedDate);
                },
                child: Text(
                  _fechaIngreso == null
                      ? 'Seleccionar fecha de ingreso'
                      : 'Fecha: ${_fechaIngreso!.day.toString().padLeft(2, '0')}/${_fechaIngreso!.month.toString().padLeft(2, '0')}/${_fechaIngreso!.year}',
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


