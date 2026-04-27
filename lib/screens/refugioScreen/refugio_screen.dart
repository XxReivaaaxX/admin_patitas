import 'package:admin_patitas/models/user_role.dart';
import 'package:admin_patitas/screens/refugioRegister/register_refugio.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/services/adopcion_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/refugioScreen/menu_refugios.dart';
import 'package:admin_patitas/widgets/custom_icon_button.dart';
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
          colorDer: AppColors.primary,
          sizeText: 20,
        ),
        // Línea divisoria debajo del AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(color: AppColors.borderLight, height: 1.0),
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,

        actions: [
          PopupMenuButton<String>(
            padding: const EdgeInsets.only(right: 18),
            icon: const Icon(Icons.person, color: AppColors.primary),
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
            return _buildRefugiosTab(false);
          } else {
            return _buildRefugiosTab(true);
          }
        },
      ),
      // boton flotante eliminado, ahora se muestra un botón dentro del título de la sección "Mis Refugios"
      /*
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
          : null,*/
    );
  }

  //     Widget para la pestaña de refugios

  Widget _buildRefugiosTab(bool pantalla) {
    return Container(
      color: AppColors.backgroundLight,
      child: Container(
        margin: pantalla == true ? EdgeInsets.all(50) : EdgeInsets.all(0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureRefugios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Si no hay datos o la lista filtrada está vacía, mostramos mensaje de bienvenida

                  if (!snapshot.hasData || _filteredRefugios.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Bienvenido ${user.email}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: SizedBox(
                            width: 300,
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ), // Estilo base
                                children: [
                                  const TextSpan(
                                    text: "Para comenzar selecciona ",
                                  ),
                                  TextSpan(
                                    text: "Crear Refugio ",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        "o pide al administrador del refugio que te agregue como colaborador.",
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        CustomIconButton(
                          icono: Icons.add,
                          texto: "Crear refugio",
                          onTap: () {
                            if (MediaQuery.of(context).size.width >= 1180) {
                              showDialog(
                                context: context,

                                barrierColor: AppColors.primary.withOpacity(
                                  0.3,
                                ),
                                builder: (context) => const RegisterRefugio(),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterRefugio(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }

                  // filtra los refugios en dos listas, refugios de admin y refugios de colaborador
                  final misRefugios = _filteredRefugios
                      .where((r) => r['role'] == 'admin')
                      .toList();
                  final colaboraciones = _filteredRefugios
                      .where((r) => r['role'] != 'admin')
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Definimos el delegate según el ancho
                      SliverGridDelegate delegate;
                      if (constraints.maxWidth > 700) {
                        delegate = SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        );
                      } else {
                        delegate =
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 8,
                            );
                      }

                      // Usamos un ListView para que toda la pantalla haga scroll
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (misRefugios.isNotEmpty) ...[
                            _buildCardContainer(
                              child: Column(
                                children: [
                                  _buildSectionTitle(
                                    "Mis Refugios",
                                    constraints,
                                  ),
                                  createGrid(delegate, misRefugios),
                                ],
                              ),
                              constraints: constraints,
                            ),
                            SizedBox(height: 24),
                          ],
                          if (colaboraciones.isNotEmpty) ...[
                            _buildCardContainer(
                              child: Column(
                                children: [
                                  _buildSectionTitle(
                                    "Refugios donde colaboras",
                                    constraints,
                                  ),
                                  createGrid(delegate, colaboraciones),
                                ],
                              ),
                              constraints: constraints,
                            ),
                          ],
                          if (misRefugios.isEmpty &&
                              colaboraciones.isNotEmpty) ...[
                            const SizedBox(height: 50),
                            Text(
                              "¿Quieres Crear un nuevo refugio?",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth > 700
                                    ? constraints.maxWidth * 0.4
                                    : 80,
                              ),
                              child: CustomIconButton(
                                icono: Icons.add,
                                texto: "Crear refugio",
                                onTap: () {
                                  if (MediaQuery.of(context).size.width >=
                                      1180) {
                                    showDialog(
                                      context: context,

                                      barrierColor: AppColors.primary
                                          .withOpacity(0.3),
                                      builder: (context) =>
                                          const RegisterRefugio(),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterRefugio(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      );
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

  Widget _buildCardContainer({
    required Widget child,
    required BoxConstraints constraints,
  }) {
    return Container(
      margin: constraints.maxWidth > 700
          ? const EdgeInsets.symmetric(horizontal: 50)
          : const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: child,
    );
  }

  // Widget auxiliar para los títulos
  Widget _buildSectionTitle(String title, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: constraints.maxWidth > 700 ? 23 : 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (title == "Mis Refugios") ...{
            CustomIconButton(
              icono: Icons.add,
              texto: "Crear refugio",
              onTap: () {
                if (MediaQuery.of(context).size.width >= 1180) {
                  showDialog(
                    context: context,

                    barrierColor: AppColors.primary.withOpacity(0.3),
                    builder: (context) => const RegisterRefugio(),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterRefugio(),
                    ),
                  );
                }
              },
            ),
          },
        ],
      ),
    );
  }

  // Crear el grid o lista de refugios

  Widget createGrid(
    SliverGridDelegate gridDelegate,
    List<Map<String, dynamic>> lista,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: lista.length,
      itemBuilder: (context, index) {
        var refugioData = lista[index];
        String refugioId = refugioData['id'];
        Map<dynamic, dynamic> data = refugioData['data'];
        String role = refugioData['role'];
        String nombre = data['nombre'] ?? 'Sin nombre';
        String direccion = data['direccion'] ?? 'Sin dirección';

        return Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _selectRefugio(refugioId, role),
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 80),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // seccion del icono
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Container(
                      width: 80,
                      color: AppColors.primary,
                      child: Icon(
                        Icons.home_work_rounded,
                        size: 32,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),

                  // seccion de texto
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      direccion,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (role == 'admin')
                          Positioned(
                            top: 8,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                // Cambiado a un color que resalte sobre blanco
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.secondary,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Admin',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
