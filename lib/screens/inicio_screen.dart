import 'package:admin_patitas/screens/filtered_animals_screen.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin_patitas/screens/refugio_screen.dart';

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
  bool _isLoadingCounts = true;

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
          _isLoadingCounts = false;
        });
      }
    } catch (e) {
      print('Error loading counts: $e');
      if (mounted) setState(() => _isLoadingCounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.principalBackgroud,
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
        color: AppColors.principalBackgroud,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1400) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard(
                    imagePath: 'assets/img/perros_principal.png',
                    title: 'Perros',
                    subtitle: 'Amigos fieles, Amorosos y Protectores',
                    count: _countPerros,
                    onTap: () => _navigateToFiltered('Perros'),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    imagePath: 'assets/img/gatos_principal.jpg',
                    title: 'Gatos',
                    subtitle: 'Independientes, Curiosos y Extrovertidos',
                    count: _countGatos,
                    onTap: () => _navigateToFiltered('Gatos'),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    imagePath: 'assets/img/otros_principal.jpg',
                    title: 'Otros',
                    subtitle: 'Conejos, Tortugas y más amigos',
                    count: _countOtros,
                    onTap: () => _navigateToFiltered('Otros'),
                    isPlaceholder: true,
                  ),
                ],
              );
            } else {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: GridView(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: constraints.maxWidth < 600 ? 0.85 : 2.5,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 16,
                  ),
                  children: [
                    _buildCard(
                      imagePath: 'assets/img/perros_principal.png',
                      title: 'Perros',
                      subtitle: 'Amigos fieles, Amorosos y Protectores',
                      count: _countPerros,
                      onTap: () => _navigateToFiltered('Perros'),
                    ),

                    _buildCard(
                      imagePath: 'assets/img/gatos_principal.jpg',
                      title: 'Gatos',
                      subtitle: 'Independientes, Curiosos y Extrovertidos',
                      count: _countGatos,
                      onTap: () => _navigateToFiltered('Gatos'),
                    ),

                    _buildCard(
                      imagePath: 'assets/img/otros_principal.jpg',
                      title: 'Otros',
                      subtitle: 'Conejos, Tortugas y más amigos',
                      count: _countOtros,
                      onTap: () => _navigateToFiltered('Otros'),
                      isPlaceholder: true,
                    ),
                  ],
                ),
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

  Widget _buildCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: isPlaceholder
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.secondary,
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: const Color.fromARGB(255, 95, 194, 161),
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isLoadingCounts
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
