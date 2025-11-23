import 'package:admin_patitas/models/user_role.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/menu_refugios.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class RefugioScreen extends StatefulWidget {
  const RefugioScreen({super.key});

  @override
  State<RefugioScreen> createState() => _RefugioScreenState();
}

class _RefugioScreenState extends State<RefugioScreen> {
  late Future<List<Map<String, dynamic>>> _futureRefugios;
  List<Map<String, dynamic>> _allRefugios = [];
  List<Map<String, dynamic>> _filteredRefugios = [];
  final TextEditingController _searchController = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadRefugios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRefugios() async {
    _futureRefugios = RoleService().getUserRefugios(user.uid);
    _allRefugios = await _futureRefugios;
    setState(() {
      _filteredRefugios = _allRefugios;
    });
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
        title: const Text(
          'Mis Refugios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
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
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(55, 148, 194, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterRefugios,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar refugio...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
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
                fillColor: Colors.white.withOpacity(0.2),
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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600
                        ? 3
                        : 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
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
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color.fromRGBO(55, 148, 194, 1),
                                    const Color.fromRGBO(55, 148, 194, 0.7),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.home_work,
                                      size: 60,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
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
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.admin_panel_settings,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Admin',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return const MenuRefugios();
            },
          );
          _loadRefugios();
        },
        icon: const Icon(Icons.add),
        label: const Text('Menú de Acciones'),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
      ),
    );
  }
}
