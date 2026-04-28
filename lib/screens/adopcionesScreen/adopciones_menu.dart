import 'package:admin_patitas/screens/adopcionesScreen/gestion_solicitudes_screen.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdopcionesMenu extends StatefulWidget {
  const AdopcionesMenu({super.key});

  @override
  State<AdopcionesMenu> createState() => _AdopcionesMenuState();
}

class _AdopcionesMenuState extends State<AdopcionesMenu> {
  String? id_refugio;
  String refugioNombre = "Refugio";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    id_refugio = PreferencesController.preferences.getString('refugio');
    _loadRefugioNombre();
  }

  Future<void> _loadRefugioNombre() async {
    if (id_refugio == null || id_refugio!.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('refugios')
          .child(id_refugio!)
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        if (data['data'] != null && data['data']['nombre'] != null) {
          refugioNombre = data['data']['nombre'];
        }
      }
    } catch (e) {
      // Usar nombre por defecto si falla
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (id_refugio == null || id_refugio!.isEmpty) {
      return const Center(child: Text("Error: No se encontró el ID del refugio"));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: GestionSolicitudesScreen(
        refugioId: id_refugio!,
        refugioNombre: refugioNombre,
      ),
    );
  }
}
