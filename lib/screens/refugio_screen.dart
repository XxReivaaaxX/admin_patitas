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

import 'package:flutter/rendering.dart';

class RefugioScreen extends StatefulWidget {
  const RefugioScreen({super.key});

  @override
  State<RefugioScreen> createState() => _RefugioScreenState();
}

class _RefugioScreenState extends State<RefugioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _futureRefugios;
  List<Map<String, dynamic>> _allRefugios = [];
  List<Map<String, dynamic>> _filteredRefugios = [];
  final TextEditingController _searchController = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser!;

  // Variables para adopciones guardadas
  List<Map<String, dynamic>> _savedAnimals = [];
  bool _isLoadingSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRefugios();
    _loadSavedAnimals();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update FAB visibility immediately
      }
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadSavedAnimals();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRefugios() async {
    _futureRefugios = RoleService().getUserRefugios(user.uid);
    _allRefugios = await _futureRefugios;
    setState(() {
      _filteredRefugios = _allRefugios;
    });
  }

  Future<void> _loadSavedAnimals() async {
    setState(() => _isLoadingSaved = true);
    try {
      final animals = await AdopcionService().getSavedAnimals(user.uid);
      setState(() {
        _savedAnimals = animals;
      });
    } catch (e) {
      log('Error loading saved animals: $e');
    } finally {
      setState(() => _isLoadingSaved = false);
    }
  }

  Future<void> _removeSavedAnimal(String animalId) async {
    try {
      await AdopcionService().removeAnimal(user.uid, animalId);
      _loadSavedAnimals(); // Recargar lista
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal eliminado de guardados')),
        );
      }
    } catch (e) {
      log('Error removing animal: $e');
    }
  }

  void _filterRefugios(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRefugios = _allRefugios;
      } else {
        _filteredRefugios = _allRefugios.where((refugio) {
          Map<dynamic, dynamic> data = refugio['data'];
          String nombre = (data['nombre'] ?? '').toString().toLowerCase();
          String direccion = (data['direccion'] ?? '').toString().toLowerCase();
          String searchLower = query.toLowerCase();
          return nombre.contains(searchLower) ||
              direccion.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _selectRefugio(String refugioId, String role) async {
    UserRole userRole = UserRole(
      userId: user.uid,
      refugioId: refugioId,
      role: role,
    );

    RoleService roleService = RoleService();
    await roleService.saveCurrentRole(userRole);
    log('Rol guardado: $role para refugio: $refugioId', name: 'RefugioScreen');

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

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Opciones de usuario',
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return menuMovil();
          } else {
            return menuWeb();
          }
        },
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
                _loadRefugios();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Menú de Acciones',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget menuMovil() {
    return Column(
      children: [
        Container(
          color: Colors.black,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Mis Refugios'),
              Tab(text: 'Mis Guardados'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Mis Refugios
              _buildRefugiosTab(false),
              // Tab 2: Mis Guardados
              _buildSavedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget menuWeb() {
    return Row(
      children: [
        // Menú Lateral (NavigationRail)
        NavigationRail(
          backgroundColor: Colors.white,
          selectedIndex: _tabController.index,
          indicatorColor: AppColors.primary,
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black),
          onDestinationSelected: (index) {
            setState(() {
              _tabController.index = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_work),
              label: Text('Mis Refugios'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.bookmark),
              label: Text('Mis Guardados'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Contenido de la pestaña (toma el resto del espacio)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Mis Refugios
              _buildRefugiosTab(true),
              // Tab 2: Mis Guardados
              _buildSavedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefugiosTab(bool pantalla) {
    return Container(
      color: AppColors.principalBackgroud,
      child: Container(
        margin: pantalla == true ? EdgeInsets.all(50) : EdgeInsets.all(0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.principalBackgroud),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRefugios,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Buscar refugio...',
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      19,
                      18,
                      18,
                    ).withOpacity(0.7),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            _filterRefugios('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.secondary.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Refugios list
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureRefugios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || _filteredRefugios.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No tienes refugios'
                                : 'No se encontraron refugios',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Crea tu primer refugio'
                                : 'Intenta con otra búsqueda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return createGrid(
                          SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                        );
                      } else {
                        return createGrid(
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createGrid(SliverGridDelegate gridDelegate) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: gridDelegate,
      itemCount: _filteredRefugios.length,
      itemBuilder: (context, index) {
        var refugioData = _filteredRefugios[index];
        String refugioId = refugioData['id'];
        Map<dynamic, dynamic> data = refugioData['data'];
        String role = refugioData['role'];
        String nombre = data['nombre'] ?? 'Sin nombre';
        String direccion = data['direccion'] ?? 'Sin dirección';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _selectRefugio(refugioId, role),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image header
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: AppColors.primary,
                  ),
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.home_work,
                              size: 60,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (role == 'admin')
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                direccion,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    if (_isLoadingSaved) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedAnimals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes animales guardados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ve a "Adopciones" para guardar tus favoritos',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedAnimals.length,
      itemBuilder: (context, index) {
        final animal = _savedAnimals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child:
                    animal['imageUrl'] != null && animal['imageUrl'].isNotEmpty
                    ? (animal['imageUrl'].startsWith('data:image')
                          ? Image.memory(
                              Uri.parse(
                                animal['imageUrl'],
                              ).data!.contentAsBytes(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Image.network(
                              animal['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  color: Colors.grey[400],
                                );
                              },
                            ))
                    : Icon(Icons.pets, color: Colors.grey[400]),
              ),
            ),
            title: Text(
              animal['nombre'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${animal['especie']} • ${animal['raza']}'),
                const SizedBox(height: 4),
                Text(
                  'Salud: ${animal['estadoSalud']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeSavedAnimal(animal['animalId']),
            ),
          ),
        );
      },
    );
  }
}
