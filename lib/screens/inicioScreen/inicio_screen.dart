import 'package:admin_patitas/screens/filtered_animals_screen.dart';
import 'package:admin_patitas/screens/inicioScreen/inicio_screen_mobile.dart';
import 'package:admin_patitas/screens/inicioScreen/inicio_screen_web.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin_patitas/screens/refugioScreen/refugio_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String _refugioNombre = 'Cargando...';
  int _countPerros = 0;
  int _countGatos = 0;
  int _countOtros = 0;
  bool isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadRefugioName();
    await _loadAnimalCounts();
  }

  Future<void> _loadRefugioName() async {
    try {
      String? refugioId = PreferencesController.preferences.getString(
        'refugio',
      );
      if (refugioId != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final refugios = await RoleService().getUserRefugios(user.uid);
          final currentRefugio = refugios.firstWhere(
            (r) => r['id'] == refugioId,
            orElse: () => {},
          );

          if (currentRefugio.isNotEmpty) {
            setState(() {
              _refugioNombre = currentRefugio['data']['nombre'] ?? 'Mi Refugio';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _refugioNombre = 'Mi Refugio';
      });
    }
  }

  Future<void> _loadAnimalCounts() async {
    try {
      String? refugioId = PreferencesController.preferences.getString(
        'refugio',
      );
      if (refugioId == null) return;

      final animals = await AnimalsService().getAnimals(refugioId);

      int perros = 0;
      int gatos = 0;
      int otros = 0;

      for (var animal in animals) {
        String especie = animal.especie.toLowerCase();
        if (especie == 'perro' || especie == 'canino') {
          perros++;
        } else if (especie == 'gato' || especie == 'felino') {
          gatos++;
        } else {
          otros++;
        }
      }

      if (mounted) {
        setState(() {
          _countPerros = perros;
          _countGatos = gatos;
          _countOtros = otros;
          isLoadingCounts = false;
        });
      }
    } catch (e) {
      print('Error loading counts: $e');
      if (mounted) setState(() => isLoadingCounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(_refugioNombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RefugioScreen()),
              (route) => false,
            );
          },
        ),
      ),

      body: Container(
        color: AppColors.backgroundLight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1180) {
              return InicioScreenMovile(
                countPerros: _countPerros,
                countGatos: _countGatos,
                countOtros: _countOtros,
                navigateToFiltered: _navigateToFiltered,
              );
            } else {
              return InicioScreenWeb(
                countPerros: _countPerros,
                countGatos: _countGatos,
                countOtros: _countOtros,
                navigateToFiltered: _navigateToFiltered,
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToFiltered(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredAnimalsScreen(category: category),
      ),
    ).then((_) => _loadAnimalCounts()); // Reload counts when returning
  }
}
