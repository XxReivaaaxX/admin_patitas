//import 'package:admin_patitas/screens/animal_screen.dart';
import 'package:admin_patitas/screens/adopcionesScreen/adopciones_menu.dart';
import 'package:admin_patitas/screens/inicioScreen/inicio_screen.dart';
import 'package:admin_patitas/screens/notificacionScreen/notificacion_screen.dart';
import 'package:admin_patitas/screens/animalsScreen/panel_animales.dart'
    show AnimalScreen;
import 'package:admin_patitas/screens/perfil_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoutesMenu extends StatelessWidget {
  final int index;
  const RoutesMenu({super.key, required this.index});

  bool _isWeb(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mobilePages = [
      const InicioScreen(),
      const AnimalScreen(),
      const AdopcionesMenu(),
      const NotificacionScreen(),
      const PerfilScreen(),
    ];

    List<Widget> webPages = [
      const InicioScreen(),
      const AnimalScreen(),
      const AdopcionesMenu(),
      const NotificacionScreen(),
      const PerfilScreen(),
    ];

    return _isWeb(context) ? webPages[index] : mobilePages[index];
  }
}
