import 'package:admin_patitas/models/routes_menu.dart';
import 'package:admin_patitas/services/notification_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/utils/state_tab.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int itemIndex = 0;
  int itemExternalIndex = 0;
  bool selectedItem = false;
  User? _currentUser;
  String? _refugioId;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _refugioId = PreferencesController.preferences.getString('refugio');
  }

  // visualisacion de menu para mobile

  Widget getMenuMovil() {
    return Scaffold(
      body: RoutesMenu(index: itemIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: itemIndex < 3 ? itemIndex : 0,
        onTap: (int index) {
          setState(() {
            itemIndex = index; // Directamente 0 o 1
          });
        },
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,

        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedFontSize: 0,
        unselectedFontSize: 12,

        items: [
          BottomNavigationBarItem(
            activeIcon: itemIndex < 2
                ? buildSelectedIcon(Icons.home, 'Principal')
                : buildUnselectedIcon(Icons.home_outlined, 'Principal'),
            icon: buildUnselectedIcon(Icons.home_outlined, 'Principal'),
            label: '',
          ),
          BottomNavigationBarItem(
            activeIcon: buildSelectedIcon(Icons.pets, 'Animales'),
            icon: buildUnselectedIcon(Icons.pets_outlined, 'Animales'),
            label: '',
          ),
          BottomNavigationBarItem(
            activeIcon: buildSelectedIcon(
              Icons.volunteer_activism,
              'Adopciones',
            ),
            icon: buildUnselectedIcon(
              Icons.volunteer_activism_outlined,
              'Adopciones',
            ),
            label: '',
          ),
        ],
      ),
    );
  }
  /*
  Widget getMenuMovil() {
    return Scaffold(
      extendBody: true,
      body: RoutesMenu(index: itemIndex),
      floatingActionButton: itemIndex == 1
          ? ValueListenableBuilder<bool>(
              valueListenable: showFabNotifier,
              builder: (context, showFab, _) {
                return showFab
                    ? _buildAddAnimalButton()
                    : const SizedBox.shrink();
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: itemIndex == 1 ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0, // Espacio entre el botón y el recorte
        color: AppColors.backgroundLight,

        child: Container(
          height: 60,

          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => itemIndex = 0),
                  child: itemIndex == 0
                      ? buildSelectedIcon(Icons.home, 'Principal')
                      : buildUnselectedIcon(Icons.home_outlined, 'Principal'),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => itemIndex = 1),
                  child: itemIndex == 1
                      ? buildSelectedIcon(Icons.pets, 'Animales')
                      : buildUnselectedIcon(Icons.pets_outlined, 'Animales'),
                ),
              ),

              // Espacio flexible para que el botón Add
              if (itemIndex == 1) const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAnimalButton() {
    return FloatingActionButton(
      onPressed: () {
        // Tu acción aquí
      },
      elevation: 4,
      backgroundColor: const Color(0xFFE8E6F5),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Color(0xFF6B5FBF), size: 26),
    );
  }*/

  //diseño de item seleccionado (para mobile)
  Widget buildSelectedIcon(IconData icon, String label) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 2),
        margin: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //item sin seleccion (para mobile)
  Widget buildUnselectedIcon(IconData icon, String label) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 2),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.backgroundDark),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  // visualizacion de menu para web
  Widget getMenuWeb() {
    return SizedBox(
      child: TabBar(
        isScrollable: true,
        onTap: (index) => setState(() => itemIndex = index),

        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,

        labelColor: itemIndex >= 3 ? Colors.black : AppColors.secondary,
        unselectedLabelColor: Colors.black,

        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),

        overlayColor: WidgetStateProperty.all(Colors.transparent),

        tabs: [
          Tab(text: 'Principal'),
          Tab(text: 'Animales'),
          Tab(text: 'Adopciones'),
        ],
      ),
    );
  }

  // menu de opciones disponibles en el appbar
  Widget getExternalMenu() {
    return Row(
      children: [
        //boton de notificacion
        StreamBuilder<int>(
          stream: NotificationsService().getUnreadCountStream(
            _currentUser!.uid,
            _refugioId!,
          ),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return IconButton(
              onPressed: () {
                setState(() {
                  itemIndex = 3;
                  itemExternalIndex = 3;
                });
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.notification_add_outlined,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),

                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: BoxConstraints(
                          minWidth: count > 9 ? 16 : 15,
                          minHeight: 15,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        //boton de perfil
        GestureDetector(
          onTap: () {
            setState(() {
              itemIndex = 4;
              itemExternalIndex = 4;
            });
          },
          child: CircleAvatar(
            radius: 15,

            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, size: 28, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // construcción de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWeb = constraints.maxWidth >= 600;
        return DefaultTabController(
          length: 5,
          initialIndex: itemIndex,
          child: Scaffold(
            appBar: AppBar(
              actionsPadding: EdgeInsets.symmetric(horizontal: 20),
              backgroundColor: AppColors.backgroundLight,
              title: LogoBar(
                sizeImg: isWeb ? 35 : 25,
                colorIzq: AppColors.primary,
                colorDer: AppColors.primary,
                sizeText: isWeb ? 20 : 15,
              ),
              actions: isWeb
                  ? [getMenuWeb(), getExternalMenu()]
                  : [getExternalMenu()],
            ),
            // mostrar la pagina principal segun el tamaño de la pantalla
            body: isWeb ? RoutesMenu(index: itemIndex) : getMenuMovil(),
          ),
        );
      },
    );
  }
}
