import 'package:admin_patitas/controllers/preferences_controller.dart';
import 'package:admin_patitas/controllers/user_controller.dart';
import 'package:admin_patitas/screens/refugio_screen.dart';
import 'package:admin_patitas/screens/sin_refugio.dart';
import 'package:admin_patitas/screens/stream_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
//import 'package:http/http.dart' as http;
import 'package:admin_patitas/screens/principal_screen.dart';
import 'package:admin_patitas/screens/register_screen.dart';

import 'package:admin_patitas/screens/panel_animales.dart';
import 'package:admin_patitas/screens/login.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesController.iniciarPref();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //UserController userController = UserController();
  //bool estado = await userController.userActive();

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
        //'/': (context) => const StreamScreen(),
        '/': (context) => SplashScreen(
          mensaje: "cargando aplicacion",
          nextRoute: '/login',
          mainScreen: false,
        ),
        '/login': (context) => const LoginScreen(),
        '/animales': (context) => const AnimalScreen(),
        '/principal': (context) => const PrincipalScreen(),
        '/register': (context) => const RegisterUser(),
        '/refugio': (context) => const RefugioScreen(),
        '/sinRefugio': (context) => const SinRefugio(),
      },
    );
  }
}
