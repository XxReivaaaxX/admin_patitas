import 'package:flutter/material.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset('assets/img/perros_principal.png', width: 150)
                ),
                const ListTile(
                  title: Text('Perro'),
                  subtitle: Text('Amigos fieles, Amorosos y Protectores'),
                ),
              ],
            ),
          ),gatos_
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset('assets/img/gatos_principal.jpg', width: 150)
                ),
                const ListTile(
                  title: Text('Gato'),
                  subtitle: Text('Independientes, Curiosos y Extrovertidos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
