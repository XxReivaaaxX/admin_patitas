import 'package:admin_patitas/screens/animal_screen.dart';
import 'package:admin_patitas/screens/inicio_screen.dart';
import 'package:admin_patitas/screens/perfil_screen.dart';
import 'package:flutter/material.dart';

class RoutesMenu extends StatelessWidget {
  final int index;
  const RoutesMenu({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    List<Widget> listPages = [
      const InicioScreen(),
      const AnimalScreen(),
      const PerfilScreen(),
    ];
    return listPages[index];
  }
}
