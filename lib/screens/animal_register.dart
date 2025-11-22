import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AnimalRegister extends StatefulWidget {
  final String idRefugio;
  const AnimalRegister({super.key, required this.idRefugio});

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
  XFile? _imagen;
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    cargarModelo();
  }

  Future<void> cargarModelo() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() => _imagen = img);
      await detectarAnimal(File(img.path));
    }
  }

  Future<void> detectarAnimal(File imagen) async {
    // Preprocesar imagen y ejecutar modelo
    var input = preprocessImage(imagen); // Implementa esta función
    var output = List.filled(1 * 120, 0).reshape([1, 120]); // Ejemplo 120 clases
    _interpreter!.run(input, output);

    int index = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    String especieDetectada = index < 60 ? 'Perro' : 'Gato'; // Ejemplo
    String razaDetectada = getLabel(index); // Implementa función para mapear índice a raza

    setState(() {
      _especie = especieDetectada;
      _raza.text = razaDetectada;
    });
  }

  Future<void> registrarAnimal() async {
    if (_imagen == null || _fechaIngreso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar imagen y fecha')),
      );
      return;
    }

    try {
      // Subir imagen a Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('animales/${DateTime.now()}.jpg');
      await ref.putFile(File(_imagen!.path));
      final imageUrl = await ref.getDownloadURL();

      // Guardar datos en Firestore
      await FirebaseFirestore.instance.collection('animales').add({
        'nombre': _nombre.text,
        'especie': _especie,
        'raza': _raza.text,
        'sexo': _sexo,
        'estadoSalud': _estadoSalud.text,
        'fechaIngreso': _fechaIngreso!.toIso8601String(),
        'imagenUrl': imageUrl,
        'idRefugio': widget.idRefugio,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado en Firebase')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro Animal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nombre, decoration: InputDecoration(labelText: 'Nombre')),
            Row(
              children: [
                Expanded(child: DropdownButtonFormField(items: ['Perro','Gato','Otro'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>_especie=v)),
                SizedBox(width:10),
                Expanded(child: DropdownButtonFormField(items:['Macho','Hembra'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>_sexo=v)),
              ],
            ),
            TextFormField(controller: _estadoSalud, decoration: InputDecoration(labelText: 'Estado de salud')),
            TextFormField(controller: _raza, decoration: InputDecoration(labelText: 'Raza')),
            ElevatedButton(onPressed: seleccionarImagen, child: Text('Tomar Foto')),
            if (_imagen != null) Image.file(File(_imagen!.path), height: 150),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                if (date != null) setState(() => _fechaIngreso = date);
              },
              child: Text(_fechaIngreso == null ? 'Seleccionar fecha' : 'Fecha: ${_fechaIngreso!.day}/${_fechaIngreso!.month}/${_fechaIngreso!.year}'),
            ),
            ElevatedButton(onPressed: registrarAnimal, child: Text('Registrar Animal')),
          ],
        ),
      ),
    );
  }
}

