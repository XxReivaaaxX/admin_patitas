import 'package:admin_patitas/screens/salud_admin.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/animal_admin.dart';
import 'package:admin_patitas/utils/state_tab.dart';
import 'package:flutter/material.dart';

class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  String? id_refugio = "";

  @override
  void initState() {
    id_refugio = PreferencesController.preferences.getString('refugio');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                AnimalAdmin(refugio: id_refugio),
                SaludAdmin(id_refugio: id_refugio),
              ],
            ),
          );
        },
      ),
    );
  }
}
