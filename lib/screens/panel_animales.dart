import 'dart:developer';

import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/animal_admin.dart';
import 'package:admin_patitas/screens/animal_register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      child: Scaffold(
        appBar: TabBar.secondary(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: <Widget>[
            Tab(text: "Administrar Animales"),
            Tab(text: "Seguimiento de salud"),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            AnimalAdmin(refugio: id_refugio),
            AnimalRegister(id_refugio: id_refugio),
          ],
        ),
      ),
    );
  }
}
