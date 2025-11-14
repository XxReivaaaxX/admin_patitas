import 'package:admin_patitas/screens/login.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:admin_patitas/screens/sin_refugio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StreamScreen extends StatelessWidget {
  const StreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, event) {
        if (event.connectionState == ConnectionState.waiting) {
          return SplashScreen(
            mensaje: "cargando aplicacion",
            nextRoute: '/',
            mainScreen: true,
          );
        }
        if (event.hasData) {
          return const SinRefugio();
        }
        return const LoginScreen();
      },
    );
  }
}
