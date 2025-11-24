import 'package:admin_patitas/models/user_role.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/services/adopcion_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/menu_refugios.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class RefugioScreen extends StatefulWidget {
  const RefugioScreen({super.key});

  @override
  State<RefugioScreen> createState() => _RefugioScreenState();
}

class _RefugioScreenState extends State<RefugioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser!;

  // ValueNotifiers para estado reactivo
  final ValueNotifier<List<Map<String, dynamic>>> _filteredRefugios = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _savedAnimals = ValueNotifier([]);
  final ValueNotifier<bool> _isLoadingSaved = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadSavedAnimals();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _filteredRefugios.dispose();
    _savedAnimals.dispose();
    _isLoadingSaved.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchRefugios() async {
    return await RoleService().getUserRefugios(user.uid);
  }

  void _loadSavedAnimals() async {
    _isLoadingSaved.value = true;
    try {
      final animals = await AdopcionService().getSavedAnimals(user.uid);
      _savedAnimals.value = animals;
    } catch (e) {
      log('Error loading saved animals: $e');
    } finally {
      _isLoadingSaved.value = false;
    }
  }

  void _removeSavedAnimal(String animalId) async {
    try {
      await AdopcionService().removeAnimal(user.uid, animalId);
      _loadSavedAnimals();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal eliminado de guardados')),
      );
    } catch (e) {
      log('Error removing animal: $e');
    }
  }

  void _filterRefugios(String query, List<Map<String, dynamic>> allRefugios) {
    if (query.isEmpty) {
      _filteredRefugios.value = allRefugios;
    } else {
      _filteredRefugios.value = allRefugios.where((refugio) {
        Map<dynamic, dynamic> data = refugio['data'];
        String nombre = (data['nombre'] ?? '').toString().toLowerCase();
        String direccion = (data['direccion'] ?? '').toString().toLowerCase();
        String searchLower = query.toLowerCase();
        return nombre.contains(searchLower) || direccion.contains(searchLower);
      }).toList();
    }
  }

  Future<void> _selectRefugio(String refugioId, String role) async {
    UserRole userRole = UserRole(
      userId: user.uid,
      refugioId: refugioId,
      role: role,
    );

    await RoleService().saveCurrentRole(userRole);
    PreferencesController.preferences.setString('refugio', refugioId);

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/principal', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: LogoBar(
          sizeImg: 25,
          colorIzq: AppColors.primary,
          colorDer: Colors.white,
          sizeText: 15,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: 'Mis Refugios'),
            Tab(icon: Icon(Icons.bookmark), text: 'Mis Guardados'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Opciones de usuario',
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Mis Refugios con FutureBuilder
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRefugios(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay refugios disponibles'));
              }

              final refugios = snapshot.data!;
              _filteredRefugios.value = refugios;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar refugio...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) => _filterRefugios(query, refugios),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _filteredRefugios,
                      builder: (context, list, _) {
                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final refugio = list[index];
                            final data = refugio['data'] as Map<dynamic, dynamic>;
                            return ListTile(
                              title: Text(data['nombre'] ?? 'Sin nombre'),
                              subtitle: Text(data['direccion'] ?? 'Sin dirección'),
                              onTap: () => _selectRefugio(refugio['id'], 'admin'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // Tab 2: Mis Guardados con ValueListenableBuilder
          ValueListenableBuilder<bool>(
            valueListenable: _isLoadingSaved,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _savedAnimals,
                builder: (context, animals, _) {
                  if (animals.isEmpty) {
                    return const Center(child: Text('No tienes animales guardados'));
                  }
                  return ListView.builder(
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return ListTile(
                        title: Text(animal['nombre'] ?? 'Sin nombre'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSavedAnimal(animal['id']),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return const MenuRefugios();
                  },
                );
                setState(() {}); // Forzar rebuild para FutureBuilder
              },
              icon: const Icon(Icons.add),
              label: const Text('Menú de Acciones'),
              backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
            )
          : null,
    );
  }
}

