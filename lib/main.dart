import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:admin_patitas/screens/principal_screen.dart';
import 'package:admin_patitas/screens/register_screen.dart';

import 'package:admin_patitas/screens/panel_animales.dart';
import 'package:admin_patitas/screens/login.dart';
import 'package:admin_patitas/screens/pantalla_bienvenida.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminPatitasApp());
}

class AdminPatitasApp extends StatelessWidget {
  const AdminPatitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),

      title: 'Refugio de Animales - AdminPatitas',

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(
          mensaje: 'Bienvenido al Refugio AdminPatitas',
          nextRoute: '/login',
        ),
        '/login': (context) => const LoginScreen(),
        '/dashboardAnimals': (context) => const DashboardAnimal(),
        '/principal': (context) => const PrincipalScreen(),
        '/register': (context) => RegisterUser(),
      },
    );
  }
}
