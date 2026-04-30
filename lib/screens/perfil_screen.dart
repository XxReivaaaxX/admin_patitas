import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantalla_carga.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? _role;
  bool _isLoading = true;
  bool _hasRefugios = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    RoleService roleService = RoleService();
    String? role = await roleService.getCurrentRole();

    // Verificar si el usuario tiene refugios
    if (_currentUser != null) {
      List<Map<String, dynamic>> refugios = await roleService.getUserRefugios(
        _currentUser!.uid,
      );
      _hasRefugios = refugios.isNotEmpty;
    }

    if (mounted) {
      setState(() {
        _role = role;
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SplashScreen(
          mensaje: 'Cerrando sesión...',
          nextRoute: '/login',
          mainScreen: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isAdmin = _role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: TextForm(
          lines: 1,
          texto: 'Perfil',
          color: AppColors.primary,
          size: 20,
          aling: TextAlign.left,
          negrita: FontWeight.bold,
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Info Card
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),

                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.secondary : Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAdmin ? 'Administrador' : 'Colaborador',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentUser?.email ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          if (isAdmin) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextForm(
                lines: 1,
                texto: 'Opciones de Administrador',
                color: Colors.black,
                size: 15,
                aling: TextAlign.left,
                negrita: FontWeight.bold,
              ),
            ),

            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.settings, color: AppColors.primary),
                title: const Text('Configurar Refugio'),
                subtitle: const Text('Editar información del refugio'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/refugio_settings');
                },
              ),
            ),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.group, color: AppColors.primary),
                title: const Text('Gestionar Colaboradores'),
                subtitle: const Text('Agregar o eliminar colaboradores'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/manage_collaborators');
                },
              ),
            ),
          ],

          // Common options
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          // Solo mostrar si el usuario NO tiene refugios
          if (!_hasRefugios)
            ListTile(
              leading: const Icon(Icons.how_to_reg, color: AppColors.primary),
              title: const Text('Registrarme como Colaborador'),
              subtitle: const Text('Permitir que me agreguen como colaborador'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/register_existing_users');
              },
            ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.primary),
            title: const Text('Acerca de'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'PetFlow',
                applicationVersion: '1.0.0',
                applicationIcon: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/img/logo_petflow.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                children: [
                  const Text('Sistema de gestión para refugios de animales.'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
