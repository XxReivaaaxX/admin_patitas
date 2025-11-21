import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/services/user_service.dart';

import 'package:admin_patitas/screens/login.dart';
import 'package:admin_patitas/screens/register_screen.dart';
import 'package:admin_patitas/screens/refugio_screen.dart';
import 'package:admin_patitas/screens/principal_screen.dart';
import 'package:admin_patitas/screens/panel_animales.dart';
import 'package:admin_patitas/screens/sin_refugio.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PreferencesController.iniciarPref();

  runApp(const AdminPatitasApp());
}

class AdminPatitasApp extends StatelessWidget {
  const AdminPatitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Refugio de Animales - AdminPatitas',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder<bool>(
        future: _verificarSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar SplashScreen mientras carga
            return SplashScreen(
              mensaje: "Verificando sesión...",
              nextRoute: '',
              mainScreen: false,
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al verificar sesión'));
          } else {
            bool isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? const RefugioScreen() : const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterUser(),
        '/refugio': (context) => const RefugioScreen(),
        '/principal': (context) => const PrincipalScreen(),
        '/animales': (context) => const AnimalScreen(),
        '/sinRefugio': (context) => const SinRefugio(),
      },
    );
  }

  Future<bool> _verificarSesion() async {
    UserController userController = UserController();
    return await userController.verificarSesion();
  }
}