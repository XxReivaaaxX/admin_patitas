import 'package:admin_patitas/screens/externalAdoptionScreen/public_adoptions_screen.dart';
import 'package:admin_patitas/services/solicitud_adopcion_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdoptionRequestForm extends StatefulWidget {
  final AdoptionAnimalGroup group;

  const AdoptionRequestForm({super.key, required this.group});

  @override
  State<AdoptionRequestForm> createState() => _AdoptionRequestFormState();
}

class _AdoptionRequestFormState extends State<AdoptionRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = SolicitudAdopcionService();

  // Controladores de texto
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _edadesNinosCtrl = TextEditingController();

  // Respuestas de filtro
  bool? _experienciaPrevia;
  String? _tipoVivienda;
  bool? _tieneNinos;
  bool? _otrasMascotas;
  String? _horasSolo;
  bool? _puedeCostearVet;

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _edadesNinosCtrl.dispose();
    super.dispose();
  }

  // ─── Validación y envío ────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar preguntas de filtro
    if (_experienciaPrevia == null ||
        _tipoVivienda == null ||
        _tieneNinos == null ||
        _otrasMascotas == null ||
        _horasSolo == null ||
        _puedeCostearVet == null) {
      _showError('Por favor responde todas las preguntas del formulario.');
      return;
    }

    if (_tieneNinos == true && _edadesNinosCtrl.text.trim().isEmpty) {
      _showError('Por favor indica las edades de los niños.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Anti-duplicado
      final yaExiste = await _service.yaEnvioSolicitud(
        refugioId: widget.group.refugioId,
        animalId: widget.group.animal.id,
        correo: _correoCtrl.text.trim(),
      );

      if (!mounted) return;

      if (yaExiste) {
        _showError(
          'Ya enviaste una solicitud para ${widget.group.animal.nombre} '
          'con este correo electrónico.',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Enviar solicitud
      await _service.enviarSolicitud(
        refugioId: widget.group.refugioId,
        refugioNombre: widget.group.refugioNombre,
        animalId: widget.group.animal.id,
        animalNombre: widget.group.animal.nombre,
        nombre: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        experienciaPrevia: _experienciaPrevia!,
        tipoVivienda: _tipoVivienda!,
        tieneNinos: _tieneNinos!,
        edadesNinos:
            _tieneNinos! ? _edadesNinosCtrl.text.trim() : '',
        otrasMascotas: _otrasMascotas!,
        horasSolo: _horasSolo!,
        puedeCostearVet: _puedeCostearVet!,
      );

      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      _showError('Ocurrió un error al enviar tu solicitud. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Atención'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('¡Solicitud Enviada!'),
          ],
        ),
        content: Text(
          '¡Gracias ${_nombreCtrl.text.trim()}! Tu solicitud para adoptar a '
          '${widget.group.animal.nombre} fue enviada correctamente.\n\n'
          'El refugio ${widget.group.refugioNombre} revisará tu solicitud '
          'y se comunicará contigo pronto.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver al detalle
              Navigator.pop(context); // Volver a la galería
            },
            child: const Text(
              'Ver más mascotas',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final animal = widget.group.animal;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Solicitud para ${animal.nombre}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Banner del animal ────────────────────────────────────────
            _AnimalBanner(group: widget.group),
            const SizedBox(height: 24),

            // ── Sección datos personales ─────────────────────────────────
            _SectionHeader(
              icon: Icons.person_outline,
              title: 'Datos Personales',
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _nombreCtrl,
              label: 'Nombre completo',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _correoCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo requerido';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _telefonoCtrl,
              label: 'Número de teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo requerido';
                if (v.trim().length < 7) return 'Ingresa un número válido';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Sección preguntas de filtro ──────────────────────────────
            _SectionHeader(
              icon: Icons.quiz_outlined,
              title: 'Preguntas del Refugio',
            ),
            const SizedBox(height: 4),
            Text(
              'Esta información ayuda al refugio a tomar la mejor decisión para ${animal.nombre}.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Q1: Experiencia previa
            _YesNoQuestion(
              question: '1. ¿Has tenido mascotas antes?',
              value: _experienciaPrevia,
              onChanged: (v) => setState(() => _experienciaPrevia = v),
            ),
            const SizedBox(height: 16),

            // Q2: Tipo de vivienda
            _DropdownQuestion<String>(
              question: '2. ¿Dónde vives?',
              value: _tipoVivienda,
              items: const ['Casa', 'Apartamento', 'Finca/Rural'],
              onChanged: (v) => setState(() => _tipoVivienda = v),
            ),
            const SizedBox(height: 16),

            // Q3: Niños en casa
            _YesNoQuestion(
              question: '3. ¿Hay niños en tu hogar?',
              value: _tieneNinos,
              onChanged: (v) => setState(() {
                _tieneNinos = v;
                if (v == false) _edadesNinosCtrl.clear();
              }),
            ),
            if (_tieneNinos == true) ...[
              const SizedBox(height: 10),
              _buildTextField(
                controller: _edadesNinosCtrl,
                label: 'Edades de los niños (ej: 3, 7, 12)',
                icon: Icons.child_care_outlined,
                validator: null,
              ),
            ],
            const SizedBox(height: 16),

            // Q4: Otras mascotas
            _YesNoQuestion(
              question: '4. ¿Tienes otras mascotas en casa?',
              value: _otrasMascotas,
              onChanged: (v) => setState(() => _otrasMascotas = v),
            ),
            const SizedBox(height: 16),

            // Q5: Horas solo
            _DropdownQuestion<String>(
              question: '5. ¿Cuántas horas al día estaría solo el animal?',
              value: _horasSolo,
              items: const ['Menos de 4 horas', 'Entre 4 y 8 horas', 'Más de 8 horas'],
              onChanged: (v) => setState(() => _horasSolo = v),
            ),
            const SizedBox(height: 16),

            // Q6: Gastos veterinarios
            _YesNoQuestion(
              question: '6. ¿Puedes cubrir los gastos veterinarios básicos?',
              value: _puedeCostearVet,
              onChanged: (v) => setState(() => _puedeCostearVet = v),
            ),
            const SizedBox(height: 32),

            // ── Botón enviar ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _isLoading ? 'Enviando...' : 'Enviar Solicitud',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Helpers de UI ─────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internos del formulario
// ─────────────────────────────────────────────────────────────────────────────

class _AnimalBanner extends StatelessWidget {
  final AdoptionAnimalGroup group;
  const _AnimalBanner({required this.group});

  @override
  Widget build(BuildContext context) {
    final animal = group.animal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.primary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: animal.imageUrl.isNotEmpty
                  ? Image.network(animal.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 40,
                      ))
                  : const Icon(Icons.pets, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${animal.especie} · ${animal.raza}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.refugioNombre,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

class _YesNoQuestion extends StatelessWidget {
  final String question;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _YesNoQuestion({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ChoiceChip(
              label: 'Sí',
              selected: value == true,
              onTap: () => onChanged(true),
              selectedColor: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _ChoiceChip(
              label: 'No',
              selected: value == false,
              onTap: () => onChanged(false),
              selectedColor: Colors.grey.shade600,
            ),
          ],
        ),
      ],
    );
  }
}

class _DropdownQuestion<T> extends StatelessWidget {
  final String question;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownQuestion({
    required this.question,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          hint: const Text('Selecciona una opción'),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? selectedColor : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
