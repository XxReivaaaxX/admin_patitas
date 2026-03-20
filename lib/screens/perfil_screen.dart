import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final String? activeRefugio = prefs.getString('refugio');

    // Verificar si el usuario tiene refugios
    if (_currentUser != null) {
      List<Map<String, dynamic>> refugios = await roleService.getUserRefugios(
        _currentUser!.uid,
      );
      _hasRefugios = refugios.isNotEmpty;
    }

    if (mounted) {
      setState(() {
        // Solo asignamos el rol si hay un refugio activo seleccionado
        _role = activeRefugio != null ? role : null;
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
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    bool isGuest = _role == null;
    bool isAdmin = _role == 'admin';

    String roleLabel = 'Explorador';
    if (!isGuest) {
      roleLabel = isAdmin ? 'Administrador' : 'Colaborador';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          // User Info Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser?.email ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isGuest 
                              ? Colors.grey.withValues(alpha: 0.2)
                              : (isAdmin ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            color: isGuest
                                ? Colors.grey[700]
                                : (isAdmin ? AppColors.secondary : AppColors.primary),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Options
          if (!isGuest && isAdmin) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                'Opciones de Administrador',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildOptionTile(
              icon: Icons.settings_outlined,
              title: 'Configurar Refugio',
              subtitle: 'Editar información y detalles del refugio',
              onTap: () => Navigator.pushNamed(context, '/refugio_settings'),
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              icon: Icons.group_outlined,
              title: 'Gestionar Colaboradores',
              subtitle: 'Añadir o eliminar accesos de equipo',
              onTap: () => Navigator.pushNamed(context, '/manage_collaborators'),
            ),
            const SizedBox(height: 20),
          ],

          // Common options
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          if (!_hasRefugios)
            _buildOptionTile(
              icon: Icons.how_to_reg_outlined,
              title: 'Registrarme como Colaborador',
              subtitle: 'Permitir que un refugio me asocie',
              onTap: () => Navigator.pushNamed(context, '/register_existing_users'),
            ),
          
          if (!_hasRefugios) const SizedBox(height: 10),

          _buildOptionTile(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Versión y detalles de la app',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Admin Patitas',
                applicationVersion: '1.0.0',
                applicationIcon: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/img/Logo_AdminPatitas.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                children: [
                  const Text('Sistema premium de gestión para refugios de animales.'),
                ],
              );
            },
          ),
          
          if (!isGuest) ...[
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.swap_horiz,
              title: 'Cambiar de Refugio',
              subtitle: 'Salir del refugio actual y elegir otro',
              onTap: () async {
                // Limpiar la preferencia del refugio actual
                await PreferencesController.preferences.remove('refugio');
                if (!mounted) return;
                // Navegar a la pantalla de selección de refugio y limpiar historial
                Navigator.pushNamedAndRemoveUntil(context, '/refugio', (route) => false);
              },
            ),
          ],
          const SizedBox(height: 30),
          
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final bool isUnauthenticated = FirebaseAuth.instance.currentUser == null;

    return InkWell(
      onTap: isUnauthenticated 
        ? () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)
        : _signOut,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isUnauthenticated ? AppColors.primary.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isUnauthenticated ? AppColors.primary.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnauthenticated ? Icons.login : Icons.logout, 
              color: isUnauthenticated ? AppColors.primary : Colors.red
            ),
            const SizedBox(width: 8),
            Text(
              isUnauthenticated ? 'Iniciar Sesión' : 'Cerrar Sesión',
              style: TextStyle(
                color: isUnauthenticated ? AppColors.primary : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
