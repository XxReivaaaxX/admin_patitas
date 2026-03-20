import 'package:flutter/material.dart';

import 'package:admin_patitas/screens/home_dashboard_screen.dart'; // Tab 0: Stats
import 'package:admin_patitas/screens/adopciones_screen.dart'; // Tab 1: Adoptions
import 'package:admin_patitas/screens/panel_animales.dart';        // Tab 2: Animals
import 'package:admin_patitas/screens/manage_collaborators.dart';   // Tab 3: Team
import 'package:admin_patitas/screens/perfil_screen.dart';         // Tab 4: Profile

class RoutesMenu extends StatelessWidget {
  final int index;
  const RoutesMenu({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    List<Widget> listPages = [
      const HomeDashboardScreen(), // 0 Inicio / Stats
      const AdopcionesScreen(),        // 1 Marketplace global de adopciones
      AnimalScreen(),        // 2 Admin de animales y salud
      const ManageCollaborators(),     // 3 Configuración Refugio
      const PerfilScreen(),        // 4 Cuenta personal
    ];
    return listPages[index];
  }
}
