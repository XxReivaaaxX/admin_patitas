import 'package:admin_patitas/screens/dashboard_animals.dart';
import 'package:admin_patitas/screens/principal_screen.dart';
import 'package:admin_patitas/screens/login_screen.dart';
import 'package:admin_patitas/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AdminPatitasApp());
}

class AdminPatitasApp extends StatelessWidget {
  const AdminPatitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      title: 'Refugio de Animales - AdminPatitas',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboardAnimals': (context) => DashboardAnimal(),
        '/principal': (context) => PrincipalScreen(),
        '/register': (context) => RegisterUser(),
      },
    );
  }
}
