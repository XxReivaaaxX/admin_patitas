import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AnimalShelterApp());
}

class AnimalShelterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refugio de Animales - AdminPatitas',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(),
    );
  }
}

// Login
class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // Puedes dejar 'login' aquí, aunque la lógica completa va en el _buildContent

  @override
  Widget build(BuildContext context) {
    // Usamos un Stack para poner el fondo y el contenido uno encima del otro
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo (Imagen y Degradado)
          _buildBackground(),

          // 2. Contenido (Logo, Campos y Botones)
          _buildContent(context),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA EL DISEÑO ---

  // Widget para el fondo de imagen con un overlay (degradado)
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // ¡Asegúrate de que esta ruta sea correcta y la imagen esté en tu carpeta 'assets'!
          image: AssetImage('assets/img/Backgound_image_1.png'), 
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(128), // 50% de opacidad (con alpha)
              Colors.black.withAlpha(230), // 90% de opacidad (con alpha)
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  // Widget principal que contiene el logo, texto y formulario
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            const SizedBox(height: 100),

            // Logo y Título (Asegúrate de tener tu logo en assets/img/logo.png)
            Image.asset(
              'assets/img/Logo_AdminPatitas.png',
              height: 100,
            ),
            const Text(
              'ADMINPATITAS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 50),

            // Texto Descriptivo con Fondo (Para mejor visibilidad)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Facilitamos la gestion para que\nmejores el cuidado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '¡REGISTRATE AHORA!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4FC3F7),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100),

            // --- Formulario ---
            // Campo Correo
            _buildTextField(
              emailController,
              'Correo electrónico',
              Icons.email,
            ),
            const SizedBox(height: 20),

            // Campo Contraseña
            _buildTextField(
              passwordController,
              'Contraseña',
              Icons.lock,
              obscureText: true,
              showVisibilityIcon: true,
            ),
            const SizedBox(height: 30),

            // Botones
            ElevatedButton(
              onPressed: () => print('Login...'), // Lógica pendiente
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Entrar', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: () => print('Registrar...'), // Lógica pendiente
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Registrar', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir los campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool showVisibilityIcon = false,
    bool showCheckmark = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        // Texto dentro del campo (Negro para contraste con fondo blanco del campo)
        labelStyle: const TextStyle(color: Colors.black),
        // Texto que flota (Blanco para contraste con fondo oscuro de la imagen)
        floatingLabelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        suffixIcon: showCheckmark 
          ? const Icon(Icons.check, color: Colors.green) 
          : (showVisibilityIcon 
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade700),
                  onPressed: () {
                    // TODO: Implementar el toggle de visibilidad
                  },
                )
              : null
            ),
      ),
    );
  }
}

// Dashboard
class DashboardScreen extends StatelessWidget {
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
                MaterialPageRoute(builder: (_) => DashboardScreen()),
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
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
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

// Registro
class RegisterAnimalScreen extends StatefulWidget {
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
  EditAnimalScreen({required this.docId, required this.data});
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
  MedicalHistoryScreen({required this.animalName});

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
