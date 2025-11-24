import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class HistorialUpdate extends StatefulWidget {
  final String? id_historial, nombre;
  final HistorialMedico historialMedico;
  const HistorialUpdate({
    super.key,
    required this.id_historial,
    required this.nombre,
    required this.historialMedico,
  });

  @override
  State<HistorialUpdate> createState() => _HistorialUpdateState();
}

class _HistorialUpdateState extends State<HistorialUpdate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tratamiento = TextEditingController();
  final TextEditingController _peso = TextEditingController();
  final TextEditingController _enfermedades = TextEditingController();
  String? _castrado;
  DateTime? _fechaRevision;

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    getValues();
  }

  void updateHistorial() async {
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
        id: widget.id_historial!,
        peso: _peso.text,
        castrado: _castrado!,
        enfermedades: _enfermedades.text,
        fechaRevision: _fechaRevision?.toIso8601String() ?? '',
        tratamiento: _tratamiento.text,
      );
      await HistorialMedicoService().updateHistorialMedico(
        widget.id_historial!,
        historialMedico,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial actualizado exitosamente')),
        );
        Navigator.pop(context, historialMedico);
      }
    } catch (e) {
      print('Excepción: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar historial: $e')),
        );
      }
    }
  }

  void getValues() {
    _peso.text = widget.historialMedico.peso;
    _enfermedades.text = widget.historialMedico.enfermedades;
    _tratamiento.text = widget.historialMedico.tratamiento;

    // Normalizar el valor de castrado para que coincida con los items del dropdown
    String castradoValue = widget.historialMedico.castrado.toLowerCase().trim();
    if (castradoValue == 'si' || castradoValue == 'sí') {
      _castrado = 'Sí';
    } else if (castradoValue == 'no') {
      _castrado = 'No';
    } else {
      // Si el valor no es válido (ej: "sin datos"), dejar null para que el usuario seleccione
      _castrado = null;
    }

    // Parse fecha de revisión
    if (widget.historialMedico.fechaRevision.isNotEmpty) {
      try {
        _fechaRevision = DateTime.parse(widget.historialMedico.fechaRevision);
      } catch (e) {
        print('Error parsing date: $e');
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
                texto: 'EDICIÓN DE HISTORIAL MÉDICO',
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
                initialValue: _castrado,
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
                    initialDate: _fechaRevision ?? DateTime.now(),
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

              // Botón de actualización
              BotonLogin(
                onPressed: updateHistorial,
                texto: 'Actualizar Historial Médico',
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
