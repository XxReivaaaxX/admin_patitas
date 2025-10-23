import 'package:admin_patitas/models/routes_menu.dart';
import 'package:admin_patitas/screens/widgets/logo_bar.dart';

import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int itemIndex = 0;

  // visualisacion para pantallas pequeñas
  Widget getMovil() {
    return Scaffold(
      body: Expanded(child: RoutesMenu(index: itemIndex)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: itemIndex,
        onTap: (int index) {
          setState(() {
            itemIndex = index;
          });
        },

        backgroundColor: Colors.white,
        selectedItemColor: Color.fromRGBO(55, 148, 194, 1),
        unselectedItemColor: Colors.black,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.pets),
            icon: Icon(Icons.pets_outlined),
            label: 'Animales',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // visualisacion para pantallas grandes
  Widget getWeb() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: itemIndex,
          onDestinationSelected: (int index) {
            setState(() {
              itemIndex = index;
            });
          },
          indicatorColor: Color.fromRGBO(55, 148, 194, 1),
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          labelType: NavigationRailLabelType.selected,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: Text('Principal'),
            ),
            NavigationRailDestination(
              selectedIcon: Icon(Icons.pets),
              icon: Icon(Icons.pets_outlined),
              label: Text('Animales'),
            ),
            NavigationRailDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: Text('Perfil'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: RoutesMenu(index: itemIndex)),
      ],
    );
  }

  // construcción de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: LogoBar(
          sizeImg: 25,
          colorIzq: Color.fromRGBO(55, 148, 194, 1),
          colorDer: Colors.white,
          sizeText: 15,
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
