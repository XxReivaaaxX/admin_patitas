import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_patitas/services/refugio_management_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class ManageCollaborators extends StatefulWidget {
  const ManageCollaborators({super.key});

  @override
  State<ManageCollaborators> createState() => _ManageCollaboratorsState();
}

class _ManageCollaboratorsState extends State<ManageCollaborators> {
  final TextEditingController _emailController = TextEditingController();
  final RefugioManagementService _managementService =
      RefugioManagementService();

  String? _refugioId;
  List<Map<String, dynamic>> _collaborators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCollaborators() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _refugioId = prefs.getString('refugio');

      if (_refugioId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el refugio')),
        );
        Navigator.pop(context);
        return;
      }

      List<Map<String, dynamic>> collaborators = await _managementService
          .getCollaborators(_refugioId!);

      setState(() {
        _collaborators = collaborators;
        _isLoading = false;
      });
    } catch (e) {
      log('Error al cargar colaboradores: $e', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCollaborator() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un email')),
      );
      return;
    }

    // Validar formato de email
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un email válido')),
      );
      return;
    }

    // Verificar que no sea el mismo usuario
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (email == currentUser?.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes agregarte a ti mismo como colaborador'),
        ),
      );
      return;
    }

    Map<String, dynamic> result = await _managementService
        .addCollaboratorByEmail(_refugioId!, email);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result['message'])));

    if (result['success']) {
      _emailController.clear();
      _loadCollaborators();
    }
  }

  Future<void> _removeCollaborator(String userId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar colaborador?'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este colaborador?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    Map<String, dynamic> result = await _managementService.removeCollaborator(
      _refugioId!,
      userId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result['message'])));

    if (result['success']) {
      _loadCollaborators();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestionar Colaboradores',
          style: TextStyle(color: AppColors.primary),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Formulario para agregar colaborador
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Agregar Colaborador',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email del Colaborador',
                                hintText: 'ejemplo@mail.com',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                focusColor: AppColors.primary,

                                filled: true,
                                fillColor: Colors.white,
                                floatingLabelStyle: TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addCollaborator,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El colaborador debe estar registrado en la aplicación',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Lista de colaboradores
                Expanded(
                  child: _collaborators.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay colaboradores',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _collaborators.length,
                          itemBuilder: (context, index) {
                            var collaborator = _collaborators[index];
                            String userId = collaborator['userId'];
                            String email = collaborator['email'];
                            String role = collaborator['role'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: role == 'admin'
                                      ? Colors.orange
                                      : const Color(0xFF4FC3F7),
                                  child: Icon(
                                    role == 'admin'
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  email,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  role == 'admin'
                                      ? 'Administrador'
                                      : 'Colaborador',
                                  style: TextStyle(
                                    color: role == 'admin'
                                        ? Colors.orange
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeCollaborator(userId),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
