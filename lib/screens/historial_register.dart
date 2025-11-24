import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

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

  final TextEditingController _tratamiento = TextEditingController();
  final TextEditingController _peso = TextEditingController();
  final TextEditingController _enfermedades = TextEditingController();
  String? _castrado;
  DateTime? _fechaRevision;

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  void registerHistorial() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaRevision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione la fecha de revisión'),
        ),
      );
      return;
    }

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial creado exitosamente')),
        );
        Navigator.pop(context, historialMedico);
      }
    } catch (e) {
      print('Excepción: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear historial: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: Text(
          'Historial Médico - ${widget.nombre}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                texto: 'CREACIÓN DE HISTORIAL MÉDICO',
                color: colorPrincipal,
                size: 26,
                aling: TextAlign.center,
                negrita: FontWeight.bold,
              ),
              const SizedBox(height: 30),

              // Peso
              Formulario(
                controller: _peso,
                text: 'Peso (kg)',
                textOcul: false,
                colorBorder: Colors.black,
                colorBorderFocus: colorPrincipal,
                colorTextForm: Colors.grey,
                colorText: Colors.black,
                sizeM: 30,
                sizeP: 10,
              ),
              const SizedBox(height: 20),

              // Castrado
              ItemFormSelection(
                onChanged: (value) => _castrado = value,
                validator: (value) =>
                    value == null ? 'Seleccione una opción' : null,
                items: ['Sí', 'No'],
                text: 'Castrado',
              ),
              const SizedBox(height: 20),

              // Enfermedades
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
              const SizedBox(height: 20),

              // Tratamiento
              Formulario(
                controller: _tratamiento,
                text: 'Tratamiento',
                textOcul: false,
                colorBorder: Colors.black,
                colorBorderFocus: colorPrincipal,
                colorTextForm: Colors.grey,
                colorText: Colors.black,
                sizeM: 30,
                sizeP: 10,
              ),
              const SizedBox(height: 20),

              // Fecha de revisión
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
                      _fechaRevision = pickedDate;
                    });
                  }
                },
                child: Text(
                  _fechaRevision == null
                      ? 'Seleccionar fecha de revisión'
                      : 'Fecha: ${_fechaRevision!.day.toString().padLeft(2, '0')}/'
                            '${_fechaRevision!.month.toString().padLeft(2, '0')}/'
                            '${_fechaRevision!.year}',
                ),
              ),
              const SizedBox(height: 30),

              // Botón de registro
              BotonLogin(
                onPressed: registerHistorial,
                texto: 'Crear Historial Médico',
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
