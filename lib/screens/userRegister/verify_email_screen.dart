import 'dart:async';

import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;

      await user?.reload();

      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Guardar usuario en realtime database
        await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(user.uid)
            .set({
              'email': user.email,
              'registered_at': DateTime.now().toIso8601String(),
            });

        timer.cancel();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(
              mensaje: 'Cargando página para iniciar sesión...',
              nextRoute: '/login',
              mainScreen: false,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.email, size: 80),

            SizedBox(height: 20),

            Text(
              'Revisa tu correo y verifica tu cuenta',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
