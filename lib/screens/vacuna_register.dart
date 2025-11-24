import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/item_form_selection.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class VacunaRegister extends StatefulWidget {
  final String refugioId;
  final String animalId;
  final String animalNombre;
  final String animalEspecie;

  const VacunaRegister({
    super.key,
    required this.refugioId,
    required this.animalId,
    required this.animalNombre,
    required this.animalEspecie,
  });

  @override
  State<VacunaRegister> createState() => _VacunaRegisterState();
}

class _VacunaRegisterState extends State<VacunaRegister> {
  final _formKey = GlobalKey<FormState>();

  String? _nombreVacuna;
  final TextEditingController _vacunaPersonalizada = TextEditingController();
  final TextEditingController _veterinario = TextEditingController();
  final TextEditingController _lote = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();
  DateTime? _fechaAplicacion;
  DateTime? _proximaFecha;

  bool _mostrarCampoPersonalizado = false;
  List<String> _vacunasDisponibles = [];

  final Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    _vacunasDisponibles = VacunaService.getVacunasPorEspecie(
      widget.animalEspecie,
    );
  }

  void _registrarVacuna() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaAplicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione la fecha de aplicación')),
      );
      return;
    }

    // Determinar el nombre de la vacuna
    String nombreFinal = _nombreVacuna ?? '';
    if (_mostrarCampoPersonalizado && _vacunaPersonalizada.text.isNotEmpty) {
      nombreFinal = _vacunaPersonalizada.text;
    }

    if (nombreFinal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione o ingrese el nombre de la vacuna'),
        ),
      );
      return;
    }

    try {
      final vacuna = Vacuna(
        id: '',
        nombre: nombreFinal,
        fecha: _fechaAplicacion!.toIso8601String(),
        proximaFecha: _proximaFecha?.toIso8601String() ?? '',
        veterinario: _veterinario.text,
        lote: _lote.text,
        observaciones: _observaciones.text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await VacunaService().createVacuna(
        widget.refugioId,
        widget.animalId,
        vacuna,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vacuna registrada exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar vacuna: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text(
          'Registrar Vacuna',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: ListView(
            children: [
              TextForm(
                lines: 2,
                texto: 'REGISTRO DE VACUNA\n${widget.animalNombre}',
                color: colorPrincipal,
                size: 24,
                aling: TextAlign.center,
                negrita: FontWeight.bold,
              ),
              const SizedBox(height: 30),

              // Selección de vacuna
              ItemFormSelection(
                initialValue: _nombreVacuna,
                onChanged: (value) {
                  setState(() {
                    _nombreVacuna = value;
                    _mostrarCampoPersonalizado =
                        value == 'Otra (Personalizada)';
                  });
                },
                validator: (value) {
                  if (!_mostrarCampoPersonalizado && value == null) {
                    return 'Seleccione una vacuna';
                  }
                  return null;
                },
                items: _vacunasDisponibles,
                text: 'Vacuna',
              ),
              const SizedBox(height: 20),

              // Campo personalizado para "Otros"
              if (_mostrarCampoPersonalizado) ...[
                Formulario(
                  controller: _vacunaPersonalizada,
                  text: 'Nombre de la vacuna personalizada',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                const SizedBox(height: 20),
              ],

              // Fecha de aplicación
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
                      _fechaAplicacion = pickedDate;
                    });
                  }
                },
                child: Text(
                  _fechaAplicacion == null
                      ? 'Seleccionar fecha de aplicación *'
                      : 'Fecha aplicación: ${_fechaAplicacion!.day.toString().padLeft(2, '0')}/'
                            '${_fechaAplicacion!.month.toString().padLeft(2, '0')}/'
                            '${_fechaAplicacion!.year}',
                ),
              ),
              const SizedBox(height: 20),

              // Próxima fecha (refuerzo)
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
                    initialDate:
                        _fechaAplicacion ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: _fechaAplicacion ?? DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _proximaFecha = pickedDate;
                    });
                  }
                },
                child: Text(
                  _proximaFecha == null
                      ? 'Seleccionar próxima fecha (opcional)'
                      : 'Próximo refuerzo: ${_proximaFecha!.day.toString().padLeft(2, '0')}/'
                            '${_proximaFecha!.month.toString().padLeft(2, '0')}/'
                            '${_proximaFecha!.year}',
                ),
              ),
              const SizedBox(height: 20),

              // Veterinario (SIN VALIDACIÓN)
              TextFormField(
                controller: _veterinario,
                decoration: InputDecoration(
                  labelText: 'Veterinario (opcional)',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorPrincipal, width: 2),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: colorPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Lote (SIN VALIDACIÓN)
              TextFormField(
                controller: _lote,
                decoration: InputDecoration(
                  labelText: 'Número de lote (opcional)',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorPrincipal, width: 2),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: colorPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Observaciones (SIN VALIDACIÓN)
              TextFormField(
                controller: _observaciones,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorPrincipal, width: 2),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: colorPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de registro
              BotonLogin(
                onPressed: _registrarVacuna,
                texto: 'Registrar Vacuna',
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

  @override
  void dispose() {
    _vacunaPersonalizada.dispose();
    _veterinario.dispose();
    _lote.dispose();
    _observaciones.dispose();
    super.dispose();
  }
}
