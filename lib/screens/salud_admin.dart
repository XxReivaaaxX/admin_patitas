import 'package:flutter/material.dart';

class SaludAdmin extends StatefulWidget {
  final String? id_refugio;
  const SaludAdmin({super.key, required this.id_refugio});

  @override
  State<SaludAdmin> createState() => _SaludAdminState();
}

class _SaludAdminState extends State<SaludAdmin> {
  String _selectedValue = '1';
  String title = '';
  Map<String, String> options = {
    '1': 'Problemas de peso',
    '2': 'Enfermedades',
    '3': 'Vacunas',
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(title.isEmpty ? 'Salud del animal' : title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedValue = value;
                title = options[value]!;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: '1', child: Text('Problemas de peso')),
              PopupMenuItem(value: '2', child: Text('Enfermedades')),
              PopupMenuItem(value: '3', child: Text('Vacunas')),
            ],
          ),
        ],
      ),
      body: switch (_selectedValue) {
        '1' => Center(child: Text('Gestión de problemas de peso')),
        '2' => Center(child: Text('Gestión de enfermedades')),
        '3' => Center(child: Text('Gestión de vacunas')),
        _ => Center(child: Text('Seleccione una opción')),
      },
    );
  }
}
