import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardAnimal extends StatefulWidget {
  const DashboardAnimal({super.key});

  @override
  State<DashboardAnimal> createState() => _DashboardAnimalState();
}

class _DashboardAnimalState extends State<DashboardAnimal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Refugio')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterAnimalScreen()),
              ),
              child: Text('Registrar Nuevo Animal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DashboardAnimal()),
              ),
              child: Text('Detección por IA'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('animals')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final animals = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final docId = animal.id;
                      final data = animal.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.pets, color: Colors.teal),
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(
                            '${data['species']} - ${data['health']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditAnimalScreen(
                                      docId: docId,
                                      data: data,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmAndDeleteAnimal(context, docId),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicalHistoryScreen(
                                animalName: data['name'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterAnimalScreen extends StatefulWidget {
  const RegisterAnimalScreen({super.key});

  @override
  _RegisterAnimalScreenState createState() => _RegisterAnimalScreenState();
}

class _RegisterAnimalScreenState extends State<RegisterAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final speciesController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final healthController = TextEditingController();

  void saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('animals').add({
        'name': nameController.text,
        'species': speciesController.text,
        'breed': breedController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'health': healthController.text,
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Animal registrado')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Animal')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: speciesController,
                decoration: InputDecoration(labelText: 'Especie'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: breedController,
                decoration: InputDecoration(labelText: 'Raza'),
              ),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: healthController,
                decoration: InputDecoration(labelText: 'Estado de salud'),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: saveAnimal, child: Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}

// Edición
class EditAnimalScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const EditAnimalScreen({super.key, required this.docId, required this.data});
  @override
  _EditAnimalScreenState createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  late TextEditingController nameController;
  late TextEditingController speciesController;
  late TextEditingController healthController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    speciesController = TextEditingController(text: widget.data['species']);
    healthController = TextEditingController(text: widget.data['health']);
  }

  void updateAnimal() async {
    await FirebaseFirestore.instance
        .collection('animals')
        .doc(widget.docId)
        .update({
          'name': nameController.text,
          'species': speciesController.text,
          'health': healthController.text,
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Animal actualizado')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Animal')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: speciesController,
              decoration: InputDecoration(labelText: 'Especie'),
            ),
            TextField(
              controller: healthController,
              decoration: InputDecoration(labelText: 'Estado de salud'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateAnimal,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

// Eliminación con confirmación
Future<void> confirmAndDeleteAnimal(BuildContext context, String docId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Eliminar animal?'),
      content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirm == true) {
    await FirebaseFirestore.instance.collection('animals').doc(docId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Animal eliminado')));
  }
}

// Historial médico (simulado)
class MedicalHistoryScreen extends StatelessWidget {
  final String animalName;
  MedicalHistoryScreen({super.key, required this.animalName});

  final List<Map<String, String>> medicalRecords = [
    {
      'date': '2025-09-01',
      'type': 'Vacuna',
      'details': 'Vacuna contra la rabia',
    },
    {'date': '2025-09-15', 'type': 'Tratamiento', 'details': 'Antibióticos'},
    {'date': '2025-10-01', 'type': 'Chequeo', 'details': 'Chequeo general'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial Médico - $animalName')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: medicalRecords.length,
          itemBuilder: (context, index) {
            final record = medicalRecords[index];
            return Card(
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.teal),
                title: Text('${record['type']} - ${record['date']}'),
                subtitle: Text(record['details']!),
              ),
            );
          },
        ),
      ),
    );
  }
}
