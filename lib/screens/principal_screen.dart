import 'package:admin_patitas/models/routes_menu.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  final int initialIndex;
  const PrincipalScreen({super.key, this.initialIndex = 0});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  late int itemIndex;
  bool _isGuestMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    itemIndex = widget.initialIndex;
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final refugioId = prefs.getString('refugio');
    
    if (mounted) {
      setState(() {
        _isGuestMode = refugioId == null;
        // Si es modo invitado y el index inicial es restringido, forzar a Adopciones (1)
        if (_isGuestMode && (itemIndex == 0 || itemIndex == 2 || itemIndex == 3)) {
          itemIndex = 1;
        }
        _isLoading = false;
      });
    }
  }

  // Mapeo de índices de pantalla (0, 1) a índices lógicos (1, 4) para invitados
  int _getLogicalIndexForGuest(int screenIndex) {
    return screenIndex == 0 ? 1 : 4;
  }

  // Mapeo de índices lógicos (1, 4) a índices de pantalla (0, 1) para invitados
  int _getScreenIndexForGuest(int logicalIndex) {
    return logicalIndex == 4 ? 1 : 0;
  }

  // visualisacion para pantallas pequeñas
  Widget getMovil() {
    final List<BottomNavigationBarItem> items = _isGuestMode 
      ? [
          const BottomNavigationBarItem(
            activeIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: 'Adopciones',
          ),
          const BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ]
      : const [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.bar_chart),
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: 'Adopciones',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.pets),
            icon: Icon(Icons.pets_outlined),
            label: 'Animales',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.group_work),
            icon: Icon(Icons.group_work_outlined),
            label: 'Equipo',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ];

    return Scaffold(
      body: RoutesMenu(index: itemIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _isGuestMode ? _getScreenIndexForGuest(itemIndex) : itemIndex,
        onTap: (int index) {
          setState(() {
            itemIndex = _isGuestMode ? _getLogicalIndexForGuest(index) : index;
          });
        },
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: items,
      ),
    );
  }

  // visualisacion para pantallas grandes
  Widget getWeb() {
    final List<NavigationRailDestination> destinations = _isGuestMode
      ? [
          const NavigationRailDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: Text('Adopciones'),
          ),
          const NavigationRailDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: Text('Perfil'),
          ),
        ]
      : const [
          NavigationRailDestination(
            selectedIcon: Icon(Icons.bar_chart),
            icon: Icon(Icons.bar_chart_outlined),
            label: Text('Inicio'),
          ),
          NavigationRailDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: Text('Adopciones'),
          ),
          NavigationRailDestination(
            selectedIcon: Icon(Icons.pets),
            icon: Icon(Icons.pets_outlined),
            label: Text('Animales'),
          ),
          NavigationRailDestination(
            selectedIcon: Icon(Icons.group_work),
            icon: Icon(Icons.group_work_outlined),
            label: Text('Equipo'),
          ),
          NavigationRailDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: Text('Perfil'),
          ),
        ];

    return Row(
      children: [
        NavigationRail(
          selectedIndex: _isGuestMode ? _getScreenIndexForGuest(itemIndex) : itemIndex,
          onDestinationSelected: (int index) {
            setState(() {
              itemIndex = _isGuestMode ? _getLogicalIndexForGuest(index) : index;
            });
          },
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          unselectedIconTheme: const IconThemeData(color: Colors.white54),
          selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
          backgroundColor: AppColors.surfaceDark,
          labelType: NavigationRailLabelType.selected,
          destinations: destinations,
        ),
        const VerticalDivider(thickness: 1, width: 1, color: Colors.transparent),
        Expanded(child: RoutesMenu(index: itemIndex)),
      ],
    );
  }

  // construcción de la pantalla principal
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const LogoBar(
          sizeImg: 25,
          colorIzq: AppColors.primary,
          colorDer: Colors.white,
          sizeText: 18,
        ),
      ),
      // mostrar la pagina principal segun el tamaño de la pantalla
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return getMovil();
          } else {
            return getWeb();
          }
        },
      ),
    );
  }
}

