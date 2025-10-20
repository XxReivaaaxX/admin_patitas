import 'package:admin_patitas/screens/dashboard_animals.dart';
import 'package:admin_patitas/screens/animals_screen.dart';
import 'package:admin_patitas/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
 
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
      title: 'Refugio de Animales - AdminPatitas',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboardAnimals': (context) => DashboardAnimal(),
        '/animalScreen': (context) => AnimalScreen(),
      },
    );
  }
}
 