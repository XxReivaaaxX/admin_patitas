import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String mensaje;
  final String nextRoute;
  final bool mainScreen;

  const SplashScreen({
    Key? key,
    required this.mensaje,
    required this.nextRoute,
    required this.mainScreen,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Verificar sesión al iniciar
    sesionActiva();
  }

  @override
  void dispose() {
    // Cancelar la suscripción para evitar fugas de memoria
    _authSubscription?.cancel();
    super.dispose();
  }

  void sesionActiva() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) async {
      if (!mounted) return;

      // Pequeño delay para que se vea el logo (opcional, pero estético)
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      if (user == null) {
        // No hay usuario, ir a Login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Usuario activo, ir a Refugio (Pantalla Principal)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/refugio',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/img/Logo_AdminPatitas.png', width: 150),
            const SizedBox(height: 60),
            Text(
              widget.mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
