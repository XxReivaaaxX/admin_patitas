import 'dart:developer';

import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/services/refugio_service.dart';
import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/refugio.dart';
import 'package:admin_patitas/models/routes_menu.dart';
import 'package:admin_patitas/models/usuario.dart';
import 'package:admin_patitas/screens/menu_refugios.dart';
import 'package:admin_patitas/screens/register_refugio.dart';
import 'package:admin_patitas/widgets/card_refugios.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefugioScreen extends StatefulWidget {
  const RefugioScreen({super.key});

  @override
  State<RefugioScreen> createState() => _RefugioScreenState();
}

class _RefugioScreenState extends State<RefugioScreen> {
  late final User user;
  late Future<List<Refugio>> _futureRefugios;

  @override
  void initState() {
    // TODO: implement initState
    user = FirebaseAuth.instance.currentUser!;

    _futureRefugios = RefugioController().getRefugios(user.uid);

    super.initState();
  }

  // visualisacion para pantallas pequeñas
  Widget getMovil() {
    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder<List<Refugio>>(
            future: _futureRefugios,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return CardRefugios(
                        onTap: () {
                          PreferencesController.preferences.setString(
                            'refugio',
                            snapshot.data![index].id,
                          );

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/principal',
                            (route) => false,
                          );
                        },
                        colorDer: Colors.black,
                        colorIzq: Colors.white,
                        sizeImg: 60,
                        sizeText: 10,
                        nombre: snapshot.data![index].nombre,
                        correo: user.email,
                      );
                      //return Text(snapshot.data![index].nombre);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return MenuRefugios();
            },
          );
          setState(() {
            _futureRefugios = RefugioController().getRefugios(user.uid);
          });
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  // visualisacion para pantallas grandes
  Widget getWeb() {
    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder<List<Refugio>>(
            future: _futureRefugios,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return CardRefugios(
                        onTap: () {
                          PreferencesController.preferences.setString(
                            'refugio',
                            snapshot.data![index].id,
                          );

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/principal',
                            (route) => false,
                          );
                        },
                        colorDer: Colors.black,
                        colorIzq: Colors.white,
                        sizeImg: 60,
                        sizeText: 10,
                        nombre: snapshot.data![index].nombre,
                        correo: user.email,
                      );
                      //return Text(snapshot.data![index].nombre);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return MenuRefugios();
            },
          );
          setState(() {
            _futureRefugios = RefugioController().getRefugios(user.uid);
          });
        },

        child: const Icon(Icons.add),
      ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            tooltip: 'Show Snackbar',
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              });
            },
          ),
        ],
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
