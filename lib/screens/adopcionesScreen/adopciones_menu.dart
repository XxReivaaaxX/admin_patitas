import 'package:admin_patitas/screens/adopcionesScreen/adopcion_screen_mobile.dart';
import 'package:admin_patitas/screens/adopcionesScreen/adopcion_screen_web.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/utils/state_tab.dart';
import 'package:flutter/material.dart';

class AdopcionesMenu extends StatefulWidget {
  const AdopcionesMenu({super.key});

  @override
  State<AdopcionesMenu> createState() => _AdopcionesMenuState();
}

class _AdopcionesMenuState extends State<AdopcionesMenu> {
  String? id_refugio = "";
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    id_refugio = PreferencesController.preferences.getString('refugio');

    super.initState();
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  Widget menuMobile() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Builder(
        builder: (context) {
          // Escucha cambios de tab
          TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              showFabNotifier.value = tabController.index == 0;
            }
          });

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: TabBar.secondary(
              isScrollable: true,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              unselectedLabelColor: Colors.black,
              tabAlignment: TabAlignment.center,
              tabs: <Widget>[
                Tab(text: "Administrar Animales"),
                Tab(text: "Seguimiento de salud"),
              ],
            ),
            body: TabBarView(
              children: <Widget>[
                AdopcionScreenWeb(refugio: id_refugio),
                AdopcionScreenMobile(refugio: id_refugio),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget menuWeb() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndexNotifier,
      builder: (context, selectedIndex, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFabNotifier.value = selectedIndex == 0;
        });

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // items del menu lateral
              Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: NavigationRail(
                  extended: true,
                  backgroundColor: Colors.white,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },

                  selectedIconTheme: IconThemeData(color: Colors.white),
                  unselectedIconTheme: IconThemeData(color: Colors.black),
                  indicatorColor: AppColors.primary,
                  selectedLabelTextStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),

                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.pets_outlined),
                      selectedIcon: Icon(Icons.pets_rounded),
                      label: Text('Administra Animales'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_outline_rounded),
                      selectedIcon: Icon(Icons.favorite_rounded),
                      label: Text('Seguimiento de Salud'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),

              //  Contenido del menu
              Expanded(
                child: IndexedStack(
                  index: selectedIndex,
                  children: [
                    AdopcionScreenWeb(refugio: id_refugio),
                    AdopcionScreenMobile(refugio: id_refugio),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return menuMobile();
        } else {
          return Container(
            color: AppColors.backgroundLight,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
            child: menuWeb(),
          );
        }
      },
    );
  }
}
