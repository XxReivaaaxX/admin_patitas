import 'package:admin_patitas/models/routes_menu.dart';
import 'package:admin_patitas/screens/principal_screen.dart';
import 'package:admin_patitas/screens/register_refugio.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class SinRefugio extends StatefulWidget {
  const SinRefugio({super.key});

  @override
  State<SinRefugio> createState() => _SinRefugioState();
}

class _SinRefugioState extends State<SinRefugio> {
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
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BotonLogin(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrincipalScreen()),
                );
              },
              texto: 'Crear Refugio',
              color: Colors.white,
              colorB: Colors.blue,
              size: 15,
              negrita: FontWeight.normal,
            ),
            BotonLogin(
              onPressed: () {},
              texto: 'Entrar a un refugio',
              color: Colors.white,
              colorB: Colors.blue,
              size: 15,
              negrita: FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}
