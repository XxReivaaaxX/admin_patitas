//import 'package:admin_patitas/screens/animal_screen.dart';
import 'package:admin_patitas/screens/adopcionesScreen/adopciones_menu.dart';
import 'package:admin_patitas/screens/inicioScreen/inicio_screen.dart';
import 'package:admin_patitas/screens/notificacionScreen/notificacion_screen.dart';
import 'package:admin_patitas/screens/animalsScreen/panel_animales.dart'
    show AnimalScreen;
import 'package:admin_patitas/screens/perfil_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ValueNotifier<int> indexMenu = ValueNotifier<int>(0);
ValueNotifier<int> adopcionesTab = ValueNotifier<int>(0);

class RoutesMenu extends StatefulWidget {
  const RoutesMenu({super.key});

  @override
  State<RoutesMenu> createState() => _RoutesMenuState();
}

class _RoutesMenuState extends State<RoutesMenu> {
  bool _isWeb(BuildContext context) {
    return kIsWeb || MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: indexMenu,
      builder: (context, currentIndex, _) {
        List<Widget> mobilePages = [
          const InicioScreen(),
          const AnimalScreen(),
          AdopcionesMenu(initialTab: adopcionesTab.value),
          const NotificacionScreen(),
          const PerfilScreen(),
        ];

        List<Widget> webPages = [
          const InicioScreen(),
          const AnimalScreen(),
          AdopcionesMenu(initialTab: adopcionesTab.value),
          const NotificacionScreen(),
          const PerfilScreen(),
        ];

        return _isWeb(context)
            ? webPages[currentIndex]
            : mobilePages[currentIndex];
      },
    );
  }
}
