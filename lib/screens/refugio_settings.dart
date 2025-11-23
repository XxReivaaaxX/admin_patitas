import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_patitas/services/refugio_management_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class RefugioSettings extends StatefulWidget {
  const RefugioSettings({super.key});

  @override
  State<RefugioSettings> createState() => _RefugioSettingsState();
}

class _RefugioSettingsState extends State<RefugioSettings> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final RefugioManagementService _managementService =
      RefugioManagementService();

  String? _refugioId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRefugioData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _loadRefugioData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _refugioId = prefs.getString('refugio');

      if (_refugioId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el refugio')),
        );
        Navigator.pop(context);
        return;
      }

      // Cargar datos del refugio
      DatabaseReference refugioRef = FirebaseDatabase.instance
          .ref()
          .child('refugios')
          .child(_refugioId!);
      DataSnapshot snapshot = await refugioRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _nombreController.text = data['nombre'] ?? '';
          _direccionController.text = data['direccion'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error al cargar datos del refugio: $e', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool success = await _managementService.updateRefugio(
      _refugioId!,
      _nombreController.text.trim(),
      _direccionController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refugio actualizado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el refugio')),
      );
    }
  }

  Future<void> _deleteRefugio() async {
    // Primera confirmación
    bool? confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar refugio?'),
        content: const Text(
          'Esta acción eliminará permanentemente el refugio y todos sus datos. '
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    // Segunda confirmación
    bool? confirm2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Última confirmación'),
        content: const Text(
          'Esta acción NO se puede deshacer. '
          'Todos los datos del refugio se perderán permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, eliminar permanentemente'),
          ),
        ],
      ),
    );

    if (confirm2 != true) return;

    // Eliminar refugio
    setState(() => _isSaving = true);

    bool success = await _managementService.deleteRefugio(_refugioId!);

    if (!mounted) return;

    if (success) {
      // Limpiar preferencias
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('refugio');
      await prefs.remove('current_role');
      await prefs.remove('current_refugio');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refugio eliminado exitosamente')),
      );

      // Navegar a la pantalla de refugios
      Navigator.pushNamedAndRemoveUntil(context, '/refugio', (route) => false);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el refugio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Refugio'),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Información del Refugio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Refugio',
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Zona de Peligro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _deleteRefugio,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Eliminar Refugio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción eliminará permanentemente el refugio y todos sus datos.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
