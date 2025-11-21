import 'package:flutter/material.dart';
import 'package:admin_patitas/screens/refugio_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RefugioScreen()),
              (route) => false, 
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCard(
            imagePath: 'assets/img/perros_principal.png',
            title: 'Perros',
            subtitle: 'Amigos fieles, Amorosos y Protectores',
          ),
          const SizedBox(height: 16),
          _buildCard(
            imagePath: 'assets/img/gatos_principal.jpg',
            title: 'Gatos',
            subtitle: 'Independientes, Curiosos y Extrovertidos',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(imagePath, height: 180, fit: BoxFit.cover),
          ),
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitle),
          ),
        ],
      ),
    );
  }
}
