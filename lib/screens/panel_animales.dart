import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/screens/salud_admin.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/animal_admin.dart';
import 'package:flutter/material.dart';

class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  String? idRefugio = "";

  @override
  void initState() {
    idRefugio = PreferencesController.preferences.getString('refugio');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0, // hide appbar title area, only show bottom tab bar
          bottom: TabBar.secondary(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textDark.withValues(alpha: 0.5),
            indicatorColor: AppColors.primary,
            tabAlignment: TabAlignment.center,
            tabs: const <Widget>[
              Tab(text: "Administrar Animales"),
              Tab(text: "Seguimiento de salud"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            AnimalAdmin(refugio: idRefugio),
            SaludAdmin(idRefugio: idRefugio),
          ],
        ),
      ),
    );
  }
}
